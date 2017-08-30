//
//  ThreadSafeMutableDictionary.h
//  PhoneBook
//
//  Created by chuonghm on 8/9/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ThreadSafeMutableDictionary : NSObject

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (NSDictionary *)toNSDictionary;
- (void)removeObjectForkey:(id <NSCopying>)key;
- (void)removeAllObjects;
- (NSArray *)allKeys;
- (NSArray *)allValues;
#pragma mark - count
- (NSUInteger)count;
@end
