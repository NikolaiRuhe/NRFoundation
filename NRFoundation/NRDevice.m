//
//  NRDevice.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-01-30.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRDevice.h"
#import "NRString.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>


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

- (void)getMemorySizesForWired:(NSUInteger *)wired active:(NSUInteger *)active inactive:(NSUInteger *)inactive free:(NSUInteger *)freeBytes physicalMemory:(NSUInteger *)physicalMemory
{
	mach_port_t hostPort = mach_host_self();

	vm_size_t pageSize;
	host_page_size(hostPort, &pageSize);

	vm_statistics_data_t statistics;
	mach_msg_type_number_t hostSize = sizeof(statistics) / sizeof(integer_t);
	kern_return_t status = host_statistics(hostPort, HOST_VM_INFO, (host_info_t)&statistics, &hostSize);
	if (status != KERN_SUCCESS) {
		NSLog(@"error in host_statistics");
		pageSize = 0;
	}

	int mib[2] = { CTL_HW, HW_MEMSIZE };
	uint64_t physicalMemoryValue;
	size_t length = sizeof(physicalMemoryValue);
	if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), &physicalMemoryValue, &length, NULL, 0) != 0)
		perror("sysctl CTL_HW, HW_MEMSIZE");

	if (wired != NULL)
		*wired = statistics.wire_count * pageSize;

	if (active != NULL)
		*active = statistics.active_count * pageSize;

	if (inactive != NULL)
		*inactive = statistics.inactive_count * pageSize;

	if (freeBytes != NULL)
		*freeBytes = statistics.free_count * pageSize;

	if (physicalMemory != NULL)
		*physicalMemory = physicalMemoryValue;
}

- (NSString *)nr_uniqueIdentifier
{
	return [self nr_uniqueIdentifierWithAccessGroup:nil];
}

- (NSString *)nr_uniqueIdentifierWithAccessGroup:(NSString *)accessGroup
{
	NSMutableDictionary *query = [NSMutableDictionary dictionary];

	// we are creating a generic password item in the keychain
	query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

	// use the security class of the item to bind the id to this device:
	query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;

	// identify the item uniquely
	query[(__bridge id)kSecAttrGeneric] = [@"com.savoysoftware.UniqueIdentifier" dataUsingEncoding:NSUTF8StringEncoding];
	query[(__bridge id)kSecAttrAccount] = @"com.savoysoftware.UniqueIdentifier";
	query[(__bridge id)kSecAttrService] = @"com.savoysoftware.UniqueIdentifier";

	// set the keychain access group, if any
	if (accessGroup != nil)
		query[(__bridge id)kSecAttrAccessGroup] = accessGroup;

	// restrict matches to one at most:
	query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

	// we want the actual, decrypted data
	query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

	CFTypeRef result = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	NSData *uniqueIDData = (__bridge_transfer NSData *)result;

	// If everything is good, return the uniqueID
	if (status == noErr)
		return [[NSString alloc] initWithData:uniqueIDData encoding:NSUTF8StringEncoding];

	// Report errors and exit.
	if (status != errSecItemNotFound) {
		if (status == errSecNotAvailable) {
			// this seems to happen on ios simulator in unit tests.
			return @"0-0-0-0";
		}
		NSLog(@"error while requesting unique id from keychain: code %d", (int)status);
		return nil;
	}

	// We did not find the item. Create a new one.
	NSString *uniqueIdentifier = [NSString nr_makeUUID];
	uniqueIDData = [uniqueIdentifier dataUsingEncoding:NSUTF8StringEncoding];

	// add the new identifier to the query
	query[(__bridge id)kSecValueData] = uniqueIDData;

	// remove query keys not needed to add a new item.
	[query removeObjectForKey:(__bridge id)kSecMatchLimit];
	[query removeObjectForKey:(__bridge id)kSecReturnData];

	// Now save the new identifier it in the keychain.
	status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);

	// If everything is good, return the new identifier.
	if (status == noErr)
		return uniqueIdentifier;

	NSLog(@"error while adding new unique id to keychain: code %d", (int)status);
	return nil;
}

@end
