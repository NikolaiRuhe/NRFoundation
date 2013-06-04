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

	union {
		const uint8_t *ptr;
		const struct load_command *com;
	} command;
	command.ptr = (const void *)(execute_header + 1);

	for (uint32_t idx = 0; idx < execute_header->ncmds; ++idx) {
		if (command.com->cmd == LC_UUID) {
			command.com += 1;

			return [NSString stringWithFormat:@"%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
					command.ptr[0], command.ptr[1], command.ptr[2], command.ptr[3],
					command.ptr[4], command.ptr[5],
					command.ptr[6], command.ptr[7],
					command.ptr[8], command.ptr[9],
					command.ptr[10], command.ptr[11], command.ptr[12], command.ptr[13], command.ptr[14], command.ptr[15]];
		}
		command.ptr += command.com->cmdsize;
	}

	return @"unknown";
}

@end
