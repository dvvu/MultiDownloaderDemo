//
//  ThreadSafeMutableArray.m
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/29/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ThreadSafeMutableArray.h"

@interface ThreadSafeMutableArray()

@property (strong,nonatomic) NSMutableArray* threadSafeArray;
@property (strong,nonatomic) dispatch_queue_t threadSafeArrayQueue;

@end

@implementation ThreadSafeMutableArray

- (instancetype)init {
    self = [super init];
    
    _threadSafeArray = [[NSMutableArray alloc]init];
    _threadSafeArrayQueue = dispatch_queue_create("com.vn.vng.zalo.ThreadSafeMutableArray", NULL);
    
    return self;
}

- (instancetype)initWithArray:(NSArray *)array {
    
    self = [super init];
    
    if (array == nil || [array count] == 0) {
        
        NSLog(@"Array must be nonnull and nonempty");
        _threadSafeArray = [[NSMutableArray alloc]init];
        
    } else {
        
        _threadSafeArray = [[NSMutableArray alloc] initWithArray:array copyItems:NO];
    }
    _threadSafeArrayQueue = dispatch_queue_create("com.vn.vng.zalo.ThreadSafeArrayQueue", NULL);
    
    return self;
}

- (void)addObject:(NSObject *)object {
    
    // Valid input object
    if (object == nil) {
        
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Add to array
    dispatch_async(_threadSafeArrayQueue, ^{
        
        [_threadSafeArray addObject:object];
    });
}

- (void)addObjectsFromArray:(NSArray *)array {
    
    // Valid input array
    if (array == nil) {
        
        NSLog(@"Array must be nonnull");
        return;
    }
    
    if ([array count] == 0) {
        
        NSLog(@"Array must be not empty");
        return;
    }
    
    // Add objects from array
    dispatch_async(_threadSafeArrayQueue, ^{
        
        [_threadSafeArray addObjectsFromArray:array];
    });
}

- (void)insertObject:(NSObject *)object atIndex:(NSUInteger)index {
    
    // Valid input object
    if (object == nil) {
        
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Valid input index
    NSUInteger numberOfElements = [self count];
    
    if (index > numberOfElements) {
        
        NSLog(@"Index %lu is out of range [0..%lu]",(unsigned long)index,(unsigned long)numberOfElements);
        return;
    }
    
    // Insert to array
    dispatch_async(_threadSafeArrayQueue, ^{
        
        [_threadSafeArray insertObject:object atIndex:index];
    });
}

- (void)removeObject:(NSObject *)object {
    
    // Valid input object
    if (object == nil) {
        
        NSLog(@"Object must be nonnull");
        return;
    }
    
    // Remove object from array
    dispatch_async(_threadSafeArrayQueue, ^{
        
        [_threadSafeArray removeObject:object];
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    
    // Valid input index
    NSUInteger numberOfElements = [self count];
    
    if (index >= numberOfElements) {
        
        NSLog(@"Index is out of range");
        return;
    }
    
    // Remove object at index from array
    dispatch_async(_threadSafeArrayQueue, ^{
        
        [_threadSafeArray removeObjectAtIndex:index];
    });
}

- (void)removeAllObjects {
    
    // Check nonempty array
    NSUInteger numberOfElements = [self count];
    
    if (numberOfElements == 0) {
        
        NSLog(@"Array is empty");
        return;
    }
    
    // Remove all objects from array
    dispatch_async(_threadSafeArrayQueue, ^{
        
        [_threadSafeArray removeAllObjects];
    });
}

- (id)objectAtIndex:(NSUInteger)index {
    
    // Valid input index
    NSUInteger numberOfElements = [self count];
    
    if (index >= numberOfElements) {
        
        NSLog(@"Index %lu is out of range [0..%lu]",(unsigned long)index,(unsigned long)numberOfElements);
        return nil;
    }
    
    // Return object at index in array
    id __block object;
    
    dispatch_sync(_threadSafeArrayQueue, ^{
        
        object = [_threadSafeArray objectAtIndex:index];
    });
    return object;
}

- (NSUInteger) count {
    
    NSUInteger __block count;
    
    dispatch_sync(_threadSafeArrayQueue, ^{
        
        count = [_threadSafeArray count];
    });
    return count;
}

- (NSArray *) filteredArrayUsingPredicate:(NSPredicate *)predicate {
    
    NSArray __block* result;
    
    dispatch_sync(_threadSafeArrayQueue, ^{
        
        result = [_threadSafeArray filteredArrayUsingPredicate:predicate];
    });
    return result;
}

- (NSInteger)indexOfObject: (NSObject *)object {
    
    NSInteger __block result;
    
    dispatch_sync(_threadSafeArrayQueue, ^{
        
        result = [_threadSafeArray indexOfObject:object];
    });
    return result;
}

- (BOOL)containsObject: (id)object {
    
    BOOL __block result;
    
    dispatch_sync(_threadSafeArrayQueue, ^{
        
        result = [_threadSafeArray containsObject:object];
    });
    return result;
}

- (NSArray *)toNSArray {
    
    NSArray __block* array;
    
    dispatch_sync(_threadSafeArrayQueue, ^{
        
        array = [[NSArray alloc] initWithArray:_threadSafeArray];
    });
    return array;
}

- (id)pop {
    
    id __block obj;
    dispatch_sync(_threadSafeArrayQueue, ^{
        
        if ([_threadSafeArray count] > 0) {
            
            obj = [_threadSafeArray lastObject];
            [_threadSafeArray removeLastObject];
        }
    });
    
    return obj;
}

@end
