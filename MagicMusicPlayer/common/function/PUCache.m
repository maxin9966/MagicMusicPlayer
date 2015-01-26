//
//  PUCache.m
//  CacheTest
//
//  Created by MA on 14-9-22.
//  Copyright (c) 2014年 ma. All rights reserved.
//

#import "PUCache.h"
#import <CommonCrypto/CommonDigest.h>

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 20; // 20 days

@interface PUCache ()

@property (strong, nonatomic) NSCache *memCache;
@property (strong, nonatomic) NSString *diskCachePath;
@property (strong, nonatomic) dispatch_queue_t ioQueue;

@end

@implementation PUCache{
    NSFileManager *_fileManager;
}

+ (PUCache *)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    return [self initWithNamespace:@"pucache_default"];
}

- (id)initWithNamespace:(NSString *)ns {
    if ((self = [super init])) {
        NSString *fullNamespace = [@"com.hackemist.PUCache." stringByAppendingString:ns];
        
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.hackemist.PUCache", DISPATCH_QUEUE_SERIAL);
        
        // Init default values
        _maxCacheAge = kDefaultCacheMaxCacheAge;
        
        // Init the memory cache
        _memCache = [[NSCache alloc] init];
        _memCache.name = fullNamespace;
        
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];
        
        _fileManager = [NSFileManager defaultManager];
        
        [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//获取路径（md5处理key 同时保留后缀名）
- (NSString *)cachePathForKey:(NSString *)key{
    if(!key.length){
        return nil;
    }
    NSString *suffixString = [[self.diskCachePath stringByAppendingPathComponent:key] pathExtension];
    if(suffixString.length){
        suffixString = [@"." stringByAppendingString:suffixString];
    }
    //md5处理
    NSString *filename = [self cachedFileNameForKey:key];
    NSString *resultPath = [self.diskCachePath stringByAppendingPathComponent:filename];
    //添加后缀
    if(suffixString.length){
        resultPath = [resultPath stringByAppendingString:suffixString];//加后缀
    }
    return resultPath;
}

#pragma mark - PUCache (private)
//md5
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

#pragma mark - Store Image
- (void)storeImage:(UIImage *)image forKey:(NSString *)key{
    if (!image || !key) {
        return;
    }    
    //内存缓存
    [self.memCache setObject:image forKey:key cost:image.size.height * image.size.width * image.scale];
    //硬盘缓存
    NSData *data = nil;
    if (image) {
        data = UIImagePNGRepresentation(image);
    }
    if (data) {
        //缓存
        [self store:data forKey:key];
    }
}

#pragma mark - Store Data
- (void)store:(NSData *)data forKey:(NSString *)key
{
    if(!data || !key){
        return;
    }
    if (![_fileManager fileExistsAtPath:_diskCachePath]) {
        [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    [data writeToFile:[self cachePathForKey:key] options:NSDataWritingAtomic error:nil];
}

#pragma mark - Exist
- (BOOL)existsWithKey:(NSString *)key
{
    if(!key.length){
        return NO;
    }
    id object = [self.memCache objectForKey:key];
    if(object){
        return YES;
    }
    return [self diskExistsWithKey:key];
}

- (BOOL)diskExistsWithKey:(NSString *)key {
    if(!key.length){
        return NO;
    }
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self cachePathForKey:key]];
    
    return exists;
}

#pragma mark - GetCacheForKey
/*
    data
 */
- (NSData *)dataFromDiskForKey:(NSString *)key {
    if(!key.length){
        return nil;
    }
    NSString *defaultPath = [self cachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:defaultPath];
    if (data) {
        return data;
    }
    return nil;
}

/*
    image
 */

//内存
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
    if(!key.length){
        return nil;
    }
    return [self.memCache objectForKey:key];
}

//硬盘
- (UIImage *)imageFromDiskForKey:(NSString *)key {
    if(!key.length){
        return nil;
    }
    NSData *data = [self dataFromDiskForKey:key];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        //解码
        image = [self decodedImageWithImage:image];
        return image;
    }
    else {
        return nil;
    }
}

- (UIImage *)imageForKey:(NSString *)key {
    if(!key.length){
        return nil;
    }
    // First check the in-memory cache...
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }
    
    // Second check the disk cache...
    UIImage *diskImage = [self imageFromDiskForKey:key];
    if (diskImage) {
        CGFloat cost = diskImage.size.height * diskImage.size.width * diskImage.scale;
        [self.memCache setObject:diskImage forKey:key cost:cost];
    }
    
    return diskImage;
}

#pragma mark - Remove
- (void)removeForKey:(NSString *)key {
    
    if (key == nil) {
        return;
    }
    [self.memCache removeObjectForKey:key];
    
    [_fileManager removeItemAtPath:[self cachePathForKey:key] error:nil];
}

#pragma mark - clear
- (void)setMaxMemoryCost:(NSUInteger)maxMemoryCost {
    self.memCache.totalCostLimit = maxMemoryCost;
}

- (NSUInteger)maxMemoryCost {
    return self.memCache.totalCostLimit;
}

//清空内存缓存
- (void)clearMemory {
    [self.memCache removeAllObjects];
}

//清空缓存
- (void)clearDisk
{
    [_fileManager removeItemAtPath:self.diskCachePath error:nil];
    [_fileManager createDirectoryAtPath:self.diskCachePath
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:NULL];
}

//清理过期的
- (void)cleanDisk {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    
    // This enumerator prefetches useful properties for our cache files.
    NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                               includingPropertiesForKeys:resourceKeys
                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                             errorHandler:NULL];
    
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
    NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
    NSUInteger currentCacheSize = 0;
    
    // Enumerate all of the files in the cache directory.  This loop has two purposes:
    //
    //  1. Removing files that are older than the expiration date.
    //  2. Storing file attributes for the size-based cleanup pass.
    NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        // Skip directories.
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        // Remove files that are older than the expiration date;
        NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
            [urlsToDelete addObject:fileURL];
            continue;
        }
        
        // Store a reference to this file and account for its total size.
        NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
        currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
        [cacheFiles setObject:resourceValues forKey:fileURL];
    }
    
    for (NSURL *fileURL in urlsToDelete) {
        [_fileManager removeItemAtURL:fileURL error:nil];
    }
    
    // If our remaining disk cache exceeds a configured maximum size, perform a second
    // size-based cleanup pass.  We delete the oldest files first.
    //缓存超过配置的最大开销 删除最老的文件
    if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
        // Target half of our maximum cache size for this cleanup pass.
        const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
        
        // Sort the remaining cache files by their last modification time (oldest first).
        NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                            return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                        }];
        
        // Delete files until we fall below our desired cache size.
        for (NSURL *fileURL in sortedFiles) {
            if ([_fileManager removeItemAtURL:fileURL error:nil]) {
                NSDictionary *resourceValues = cacheFiles[fileURL];
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                
                if (currentCacheSize < desiredCacheSize) {
                    break;
                }
            }
        }
    }
}

- (void)backgroundCleanDisk {
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self cleanDisk];
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    });
}

#pragma mark - get count and size
- (NSUInteger)getDiskCount {
    __block NSUInteger count = 0;
    NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
    count = [[fileEnumerator allObjects] count];

    return count;
}

- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

- (void)calculateSizeWithCompletionBlock:(PUCalculateSizeBlock)completionBlock {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    
    NSUInteger fileCount = 0;
    NSUInteger totalSize = 0;
    
    NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                               includingPropertiesForKeys:@[NSFileSize]
                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                             errorHandler:NULL];
    
    for (NSURL *fileURL in fileEnumerator) {
        NSNumber *fileSize;
        [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
        totalSize += [fileSize unsignedIntegerValue];
        fileCount += 1;
    }
    
    if (completionBlock) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            completionBlock(fileCount, totalSize);
        });
    }
}

#pragma mark - decoder
- (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images) {
        // Do not decode animated images
        return image;
    }
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    // If failed, return undecompressed image
    if (!context) return image;
    
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

//rename
- (void)rename:(NSString*)key newKey:(NSString*)newKey
{
    if(!key.length || !newKey.length){
        return;
    }
    NSString *originPath = [self cachePathForKey:key];
    NSString *newPath = [self cachePathForKey:newKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:originPath]) {
        [[NSFileManager defaultManager] moveItemAtPath:originPath toPath:newPath error:nil];
    }
}

@end
