//
//  NRUtilities.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-07-11.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation NSString (NRString)

- (NSString *)nr_stringByAddingAllRequiredPercentEscapesUsingEncoding:(NSStringEncoding)encoding
{
	CFStringRef string = CFURLCreateStringByAddingPercentEscapes(NULL,
																 (__bridge CFStringRef)self,
																 NULL,
																 CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
																 CFStringConvertNSStringEncodingToEncoding(encoding));
	return (__bridge_transfer NSString *)string;
}

@end
