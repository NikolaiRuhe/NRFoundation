//
//  NDDevice.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-01-30.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRDevice.h"
#include <sys/types.h>
#include <sys/sysctl.h>


@implementation UIDevice (NRDevice)

+ (BOOL)isIPad
{
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL)isIPhone
{
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

- (NSString *)hardwareIdentifier
{
	int mib[] = {CTL_HW, HW_MACHINE};
	size_t size = 0;
	sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &size, NULL, 0);
	NSMutableData *data = [NSMutableData dataWithLength:size];
	sysctl(mib, sizeof(mib) / sizeof(mib[0]), [data mutableBytes], &size, NULL, 0);

	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
