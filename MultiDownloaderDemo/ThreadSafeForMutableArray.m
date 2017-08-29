//
//  ThreadSafeForMutableArray.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/29/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ThreadSafeForMutableArray.h"

@interface ThreadSafeForMutableArray()

@property (nonatomic) NSMutableArray* threadSafeArray;
@property (nonatomic) dispatch_queue_t threadSafeForArrayQueue;

@end

@implementation ThreadSafeForMutableArray


#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _threadSafeArray = [[NSMutableArray alloc]init];
        _threadSafeForArrayQueue = dispatch_queue_create("ThreadSafeForArray_Queue", NULL);
    }
    return self;
}

#pragma mark - addObject

- (void)addObject:(NSObject *)object {
    
    // Valid input object
    if (object == nil) {
        
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Add to array
    dispatch_async(_threadSafeForArrayQueue, ^{
        
        [_threadSafeArray addObject:object];
    });
}

#pragma mark - removeObject

- (void)removeObject:(NSObject *)object {
    
    // Valid input object
    if (object == nil) {
        
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Remove object from array
    dispatch_async(_threadSafeForArrayQueue, ^{
        
        [_threadSafeArray removeObject:object];
    });
}

#pragma mark - objectAtIndex

- (id)objectAtIndex:(NSUInteger)index {
    
    // Valid input index
    NSUInteger numberOfElements = [self count];
    
    if (index >= numberOfElements) {
        
        NSLog(@"Index %lu is out of range [0..%lu]",(unsigned long)index,(unsigned long)numberOfElements);
        return nil;
    }
    
    // Return object at index in array
    id __block object;
    
    dispatch_sync(_threadSafeForArrayQueue, ^{
        
        object = [_threadSafeArray objectAtIndex:index];
    });
    return object;
}

#pragma mark - count

- (NSUInteger)count {
    
    NSUInteger __block count;
    
    dispatch_sync(_threadSafeForArrayQueue, ^{
        
        count = [_threadSafeArray count];
    });
    return count;
}

@end
