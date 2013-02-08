//
//  NRControl.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRControl.h"
#import "NRObject.h"
#import <objc/runtime.h>


static NSString *NRControlActionKey = @"NRControlActionKey";

@interface NRControlTrampoline : NSObject
@property (nonatomic, copy) NRControlAction action;
@end

@implementation NRControlTrampoline
@synthesize action = _action;

- (void)fireAction:(UIControl *)sender
{
	self.action(sender);
}

@end



@implementation UIControl (NRControl)

- (void)nr_addAction:(NRControlAction)action forControlEvents:(UIControlEvents)controlEvents
{
	if (action == nil) {
		NSLog(@"could not add block action: block is nil");
		return;
	}

	NRControlTrampoline *trampoline = [[NRControlTrampoline alloc] init];
	trampoline.action = action;
	[self addTarget:trampoline action:@selector(fireAction:) forControlEvents:controlEvents];
	NSMutableArray *trampolines = objc_getAssociatedObject(self, &NRControlActionKey);
	if (trampolines == nil) {
		trampolines = [NSMutableArray array];
		objc_setAssociatedObject(self, &NRControlActionKey, trampolines, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	[trampolines addObject:trampoline];
}

- (void)nr_removeAllBlockActions
{
	NSMutableArray *trampolines = objc_getAssociatedObject(self, &NRControlActionKey);
	for (NRControlTrampoline *trampoline in trampolines)
		[self removeTarget:trampoline action:@selector(fireAction:) forControlEvents:UIControlEventAllEvents];
	objc_setAssociatedObject(self, &NRControlActionKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
