//
//  NRControlAdditions.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRControlAdditions.h"
#import "NRObjectAdditions.h"


static NSString *NRControlAdditionsBlockActionKey = @"NRControlAdditionsBlockActionKey";

@interface NRControlTrampoline : NSObject
@property (nonatomic, copy) NRControlBlockAction blockAction;
@end

@implementation NRControlTrampoline
@synthesize blockAction = _blockAction;

- (void)fireAction:(UIControl *)sender
{
	self.blockAction(sender);
}

@end



@implementation UIControl (NRControlAdditions)

- (void)nr_addBlockAction:(NRControlBlockAction)blockAction forControlEvents:(UIControlEvents)controlEvents
{
	if (blockAction == nil) {
		NSLog(@"could not add block action: block is nil");
		return;
	}

	NRControlTrampoline *trampoline = [[NRControlTrampoline alloc] init];
	trampoline.blockAction = blockAction;
	[self addTarget:trampoline action:@selector(fireAction:) forControlEvents:controlEvents];
	[self nr_addObject:trampoline forKey:NRControlAdditionsBlockActionKey];
}

- (void)nr_removeBlockActions
{
	for (NRControlTrampoline *trampoline in [self nr_objectsForKey:NRControlAdditionsBlockActionKey])
		[self removeTarget:trampoline action:@selector(fireAction:) forControlEvents:UIControlEventAllEvents];
	[self nr_removeObjectsForKey:NRControlAdditionsBlockActionKey];
}

@end
