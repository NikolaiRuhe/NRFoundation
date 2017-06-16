//
//  NRString.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-01-30.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRString.h"


@implementation NSString (NRString)

+ (NSString *)nr_makeUUID
{
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
	CFRelease(uuid);
	return uuidString;
}

- (NSString *)nr_stringByAddingAllRequiredPercentEscapesUsingEncoding:(NSStringEncoding)encoding
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	CFStringRef string = CFURLCreateStringByAddingPercentEscapes(NULL,
																 (__bridge CFStringRef)self,
																 NULL,
																 CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
																 CFStringConvertNSStringEncodingToEncoding(encoding));
	return (__bridge_transfer NSString *)string;
#pragma clang diagnostic pop
}

@end
