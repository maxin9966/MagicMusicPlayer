//
//  PUCache.h
//  CacheTest
//
//  Created by MA on 14-9-22.
//  Copyright (c) 2014年 ma. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    数据缓存管理
 */

//定义block
typedef void(^PUCacheNoParamsBlock)();

typedef void(^PUCheckCacheCompletionBlock)(BOOL isInCache);

typedef void(^PUCacheCompletionBlock)(BOOL isSuccess);

typedef void(^PUCalculateSizeBlock)(NSUInteger fileCount, NSUInteger totalSize);


@interface PUCache : NSObject

- (id)initWithNamespace:(NSString *)ns;

//最长缓存时间
@property (assign, nonatomic) NSInteger maxCacheAge;

//最大缓存大小
@property (assign, nonatomic) NSUInteger maxCacheSize;

//最大图片内存开销
@property (assign, nonatomic) NSUInteger maxMemoryCost;

+ (PUCache *)sharedInstance;

//isExist
- (BOOL)existsWithKey:(NSString *)key;

- (BOOL)diskExistsWithKey:(NSString *)key;

//store
- (void)store:(NSData *)data forKey:(NSString *)key;

- (void)storeImage:(UIImage *)image forKey:(NSString *)key;

//get cache
- (NSData *)dataFromDiskForKey:(NSString *)key;

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;
- (UIImage *)imageFromDiskForKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;

//remove
- (void)removeForKey:(NSString *)key;

//clear
- (void)clearMemory;
- (void)clearDisk;

//get count and size
- (NSUInteger)getDiskCount;
- (NSUInteger)getSize;
- (void)calculateSizeWithCompletionBlock:(PUCalculateSizeBlock)completionBlock;

//get file path
- (NSString *)cachePathForKey:(NSString *)key;

//rename
- (void)rename:(NSString*)key newKey:(NSString*)newKey;

@end
