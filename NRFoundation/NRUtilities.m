//
//  NRUtilities.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-07-11.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRUtilities.h"

@implementation NSLocale (NRLocale)

+ (NSString *)nr_POSIXLocaleIdentifier
{
	return @"en_US_POSIX";
}

+ (instancetype)nr_POSIXLocale
{
	return [[self alloc] initWithLocaleIdentifier:[self nr_POSIXLocaleIdentifier]];
}

@end
