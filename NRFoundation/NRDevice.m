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
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>


@implementation UIDevice (NRDevice)

+ (BOOL)isIPad
{
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL)isIPhone
{
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

- (NSString *)modelID
{
	int mib[] = {CTL_HW, HW_MACHINE};
	size_t size = 0;
	sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &size, NULL, 0);
	NSMutableData *data = [NSMutableData dataWithLength:size];
	sysctl(mib, sizeof(mib) / sizeof(mib[0]), [data mutableBytes], &size, NULL, 0);

	if (((uint8_t *)[data mutableBytes])[size - 1] == 0)
		[data setLength:size - 1];

	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)MACAddress
{
	return [self MACAddressForInterface:@"en0"];
}

- (NSString *)MACAddressForInterface:(NSString *)interface
{
	int interfaceIndex = if_nametoindex([interface UTF8String]);
	if (interfaceIndex < 1)
		return nil;

	int mib[] = { CTL_NET, AF_ROUTE, 0, AF_LINK, NET_RT_IFLIST, interfaceIndex };

	size_t size;
	if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &size, NULL, 0) != 0)
		return nil;

	NSMutableData *buffer = [NSMutableData dataWithLength:size];
	struct if_msghdr *if_msghdr = [buffer mutableBytes];
	if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), if_msghdr, &size, NULL, 0) != 0)
		return nil;

	const struct sockaddr_dl *sockaddr = (const struct sockaddr_dl *)(if_msghdr + 1);
	const uint8_t *macAddress = (const uint8_t *)(sockaddr->sdl_data + sockaddr->sdl_nlen);

	return [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
			(int)macAddress[0],
			(int)macAddress[1],
			(int)macAddress[2],
			(int)macAddress[3],
			(int)macAddress[4],
			(int)macAddress[5]];
}

@end
