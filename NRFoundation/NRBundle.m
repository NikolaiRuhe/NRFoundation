//
//  NRBundle.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-01-30.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRBundle.h"
#import <mach-o/ldsyms.h>
#include <dlfcn.h>


@implementation NSBundle (NRBundle)

+ (NSString *)executableLinkEditorUUID
{
	const struct mach_header *execute_header = dlsym(RTLD_MAIN_ONLY, MH_EXECUTE_SYM);

	if (execute_header == NULL)
		return @"unknown";

	const uint8_t *command = (const uint8_t *)(execute_header + 1);

	for (uint32_t idx = 0; idx < execute_header->ncmds; ++idx) {
		if (((const struct load_command *)command)->cmd == LC_UUID) {
			command += sizeof(struct load_command);

			return [NSString stringWithFormat:@"%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
					command[0], command[1], command[2], command[3],
					command[4], command[5],
					command[6], command[7],
					command[8], command[9],
					command[10], command[11], command[12], command[13], command[14], command[15]];
		} else {
			command += ((const struct load_command *)command)->cmdsize;
		}
	}

	return @"unknown";
}

@end
