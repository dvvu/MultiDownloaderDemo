//
//  ThreadSafeForMutableArray.h
//  MultiDownloaderDemo
//
//  Created by Doan Van Vu on 8/29/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadSafeForMutableArray : NSObject

#pragma mark - init
- (instancetype)init;

#pragma mark - addObject
- (void)addObject:(NSObject *)object;

#pragma mark - removeObject
- (void)removeObject:(NSObject *)object;

#pragma mark - objectAtIndex
- (id)objectAtIndex:(NSUInteger)index;

#pragma mark - count
- (NSUInteger)count;

@end
