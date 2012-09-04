//
//  NRControl.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRControl.h"
#import "NRObject.h"


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
	[self nr_addObject:trampoline forKey:NRControlActionKey];
}

- (void)nr_removeAllBlockActions
{
	for (NRControlTrampoline *trampoline in [self nr_objectsForKey:NRControlActionKey])
		[self removeTarget:trampoline action:@selector(fireAction:) forControlEvents:UIControlEventAllEvents];
	[self nr_removeObjectsForKey:NRControlActionKey];
}

@end
