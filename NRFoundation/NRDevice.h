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
@property (nonatomic, readonly) NSString *MACAddress;

- (NSString *)MACAddressForInterface:(NSString *)interface;

- (void)getMemorySizesForWired:(NSUInteger *)wired active:(NSUInteger *)active inactive:(NSUInteger *)inactive free:(NSUInteger *)freeBytes physicalMemory:(NSUInteger *)physicalMemory;

@end
