//
//  NRDigest.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-11-28.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NRDigest : NSObject <NSCopying>

- (BOOL)isEqualToDigest:(NRDigest *)digest;

@end


@interface NRMutableDigest : NRDigest <NSMutableCopying>

+ (NRMutableDigest *)digest;

- (void)updateWithBytes:(const void *)bytes length:(NSUInteger)length;
- (void)updateWithData:(NSData *)data;
- (void)updateWithString:(NSString *)string;
- (void)updateWithString:(NSString *)string normalize:(BOOL)normalize;
- (void)updateWithDigest:(NRDigest *)digest;

@end
