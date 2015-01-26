/** @file XLoader.m
 内部使用NSOperationQueue来实现多线程操作
 */

#import "XLoader.h"

/// 仅供内部使用
@interface XLoaderTask:NSObject

@property (atomic) BOOL isRemoved;//如果此值为TRUE，则表示已经卸载了这个对象。相当于已经针对这个对象调用了cancelObject:
@property (nonatomic,strong) id	key;
@property (nonatomic,strong) id	object;
@property (nonatomic,strong) XLoaderLoadBlock loadBlock;
@property (nonatomic,strong) XLoaderFinishedBlock finishedBlock;

-(void) run;//执行

@end

@implementation XLoaderTask

-(void) run
{
	self.object = self.loadBlock();
}
@end

@interface XLoader()
{
	NSMutableDictionary* dicTasks;//待加载的任务
}

@end

@implementation XLoader

+(XLoader*)defaultLoader
{
	static XLoader* hidden_DefaultXLoder = nil;
	if(hidden_DefaultXLoder==nil)
	{
		@synchronized(self)
		{
			if(hidden_DefaultXLoder==nil)
			{
				hidden_DefaultXLoder = [[XLoader alloc] init];
			}
		}
	}
	return hidden_DefaultXLoder;
}

-(id) init
{
	if((self = [super init]))
	{
		dicTasks	= [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Task
+(NSOperationQueue*) operationQueue
{
	static NSOperationQueue* xLoaderTaskQueue = nil;

	if(xLoaderTaskQueue==nil)
	{
		@synchronized(self)
		{
			if(xLoaderTaskQueue==nil)
			{
				xLoaderTaskQueue = [[NSOperationQueue alloc] init];
				xLoaderTaskQueue.maxConcurrentOperationCount = 2;
			}
		}
	}
	return xLoaderTaskQueue;
}

//此函数由后台线程调用
-(void) runATask:(XLoaderTask *)task
{
	if(task.isRemoved)
	{
		return;
	}
	[task run];//执行任务
	if(task.isRemoved)
	{
		return;
	}

	//任务完成后提交到主线程
	[self performSelectorOnMainThread:@selector(taskFinished:) withObject:task waitUntilDone:NO];
}

//此方法只在主线程中被调用
-(void) taskFinished:(XLoaderTask*)task
{
	@synchronized(self)
	{
		[dicTasks removeObjectForKey:task.key];
	}
	if(task.isRemoved)
	{
		return;
	}

	if(task.finishedBlock)
		task.finishedBlock(task.key, task.object);
}

#pragma mark Load/Cancel
-(void) loadForKey:(id)key loadBlock:(XLoaderLoadBlock)loadBlock finishedBlock:(XLoaderFinishedBlock)finishedBlock
{
	if(key==nil || loadBlock==nil)
		return;
	XLoaderTask* task	= [[XLoaderTask alloc] init];
	task.key	= key;
	task.loadBlock	= loadBlock;
	task.finishedBlock = finishedBlock;
	@synchronized(self)
	{
		XLoaderTask* oldTask = [dicTasks objectForKey:key];
		if(oldTask)
			oldTask.isRemoved = TRUE;//取消旧任务

		[dicTasks setObject:task forKey:key]; //添加新任务
	}

	NSInvocationOperation* op	= [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runATask:) object:task];
	[[XLoader operationQueue] addOperation:op];
}

-(void) cancelByKey:(id)key
{
	@synchronized(self)
	{
		XLoaderTask* task	= [dicTasks objectForKey:key];
		if(task)
		{
			task.isRemoved	= TRUE;
			[dicTasks removeObjectForKey:key];
		}
	}
}

-(void) cancelAll
{
	@synchronized(self)
	{
		for (XLoaderTask* task in dicTasks.allValues)
		{
			task.isRemoved	= TRUE;
		}
		[dicTasks removeAllObjects];
	}
}

@end
