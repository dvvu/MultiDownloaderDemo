//
//  ThreadSafeMutableDictionary.m
//  PhoneBook
//
//  Created by chuonghm on 8/9/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ThreadSafeMutableDictionary.h"

@interface ThreadSafeMutableDictionary()

@property (nonatomic) NSMutableDictionary* threadSafeDictionary;
@property (nonatomic) dispatch_queue_t threadSafeDictionaryQueue;

@end

@implementation ThreadSafeMutableDictionary

- (instancetype)init {
    
    self = [super init];
    
    _threadSafeDictionary = [[NSMutableDictionary alloc]init];
    _threadSafeDictionaryQueue = dispatch_queue_create("threadSafeDictionar_Queue", NULL);
    
    return self;
}

- (id)objectForKeyedSubscript:(id)key {
    
    NSObject* __block result;
    
    dispatch_sync(_threadSafeDictionaryQueue, ^{
        
        result = _threadSafeDictionary[key];
    });
    
    return result;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    
    dispatch_async(_threadSafeDictionaryQueue, ^{
        
        _threadSafeDictionary[key] = obj;
    });
}

- (NSDictionary *)toNSDictionary {
    
    NSDictionary* __block result;
    
    dispatch_sync(_threadSafeDictionaryQueue, ^{
        
        result = _threadSafeDictionary;
    });
    
    return result;
}

- (void)removeObjectForkey:(NSString *)key {
    
    dispatch_async(_threadSafeDictionaryQueue, ^{
        
        [_threadSafeDictionary removeObjectForKey:key];
    });
}

- (void)removeAllObjects {
    
    dispatch_async(_threadSafeDictionaryQueue, ^{
        
        [_threadSafeDictionary removeAllObjects];
    });
}

- (NSArray *)allKeys {
    
    NSArray* __block keys;
    
    dispatch_sync(_threadSafeDictionaryQueue, ^{
        
        keys = [_threadSafeDictionary allKeys];
    });
    
    return keys;
}

- (NSArray *)allValues {
    
    NSArray* __block values;
    
    dispatch_sync(_threadSafeDictionaryQueue, ^{
        
        values = [_threadSafeDictionary allValues];
    });
    
    return values;
}

#pragma mark - count

- (NSUInteger)count {
    
    NSUInteger __block count;
    
    dispatch_sync(_threadSafeDictionaryQueue, ^{
        
        count = [_threadSafeDictionary count];
    });
    return count;
}

@end
