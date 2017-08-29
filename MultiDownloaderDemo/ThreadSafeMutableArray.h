//
//  ThreadSafeMutableArray.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/29/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadSafeMutableArray : NSObject

- (instancetype)init;
- (instancetype)initWithArray:(NSArray *)array;

- (void)addObject:(NSObject *)object;
- (void)addObjectsFromArray:(NSArray *)array;

- (void)insertObject:(NSObject *)object atIndex:(NSUInteger)index;

- (void)removeObject:(NSObject *)object;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;

- (id)pop;
- (id)objectAtIndex:(NSUInteger)index;

- (NSUInteger)count;
- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *) predicate;
- (NSInteger)indexOfObject:(NSObject *)object;
- (BOOL)containsObject: (id)object;
- (NSArray *)toNSArray;

@end
