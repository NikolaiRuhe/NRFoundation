//
//  NRDevice.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-01-30.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIDevice (NRDevice)

+ (BOOL)isIPad;

+ (BOOL)isIPhone;

@property (nonatomic, readonly) NSString *modelID;

- (void)getMemorySizesForWired:(NSUInteger *)wired active:(NSUInteger *)active inactive:(NSUInteger *)inactive free:(NSUInteger *)freeBytes physicalMemory:(NSUInteger *)physicalMemory;

- (NSString *)nr_uniqueIdentifier;
- (NSString *)nr_uniqueIdentifierWithAccessGroup:(NSString *)accessGroup;

@end
