/** @file XLoader.h
 */

#import <Foundation/Foundation.h>

typedef void (^XLoaderFinishedBlock)(id key, id object);
typedef id (^XLoaderLoadBlock)(void);

/// 异步对象加载器
/** 加载过程都是在非主线程中进行的，通知方法都是在主线程中执行的 */
@interface XLoader : NSObject

+(XLoader*)defaultLoader;

/// 加载一个对象
/** 对象的加载工作会在后台线程中进行，当加载完成后，XLoader会通知委托对象
 @param key 可以看做是加载任务的名字。重复提交同一个名字的任务，后提交的任务会覆盖先提交的
 @param loadBlock 实际加载对象的BLOCK，返回加载好的对象，加载失败返回nil
 id (^)(){
	return obj;
 }
 @param finishedBlock 加载完成后会被调用的BLOCK，总是在主线程中调用。
 */
-(void) loadForKey:(id)key loadBlock:(XLoaderLoadBlock)loadBlock finishedBlock:(XLoaderFinishedBlock)finishedBlock;

/// 取消加载一个对象
/** 取消加载一个尚未加载完的对象。被取消的对象是不会触发委托方法的。
 @param keyOfObject 对象的Key
 */
-(void) cancelByKey:(id)keyOfObject;
/// 取消加载所有尚未加载完的对象。被取消的对象是不会触发委托方法的。
-(void) cancelAll;
@end



