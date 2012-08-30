//
//  NRActionSheetAdditions.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRFoundation.h"

static NSString *NRActionSheetAdditionsCompletionBlocksKey = @"NRActionSheetAdditionsCompletionBlocksKey";

@interface NRActionSheetTrampoline : NSObject <UIActionSheetDelegate>
@property (nonatomic, retain) NSMutableDictionary *actions;
@end

@implementation NRActionSheetTrampoline
@synthesize actions = _actions;

- (NSMutableDictionary *)actions
{
	if (_actions == nil)
		_actions = [NSMutableDictionary dictionary];
	return _actions;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// Added a button without block action?
	if ([self.actions count] <= buttonIndex)
		return;

	NRActionSheetActionBlock action = [self.actions objectForKey:@(buttonIndex)];
	if (action != nil)
		action(actionSheet, buttonIndex);
	actionSheet.delegate = nil;
	[actionSheet nr_removeObjectsForKey:NRActionSheetAdditionsCompletionBlocksKey];
}

@end



@implementation UIActionSheet (NRActionSheetAdditions)

- (id)nr_initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle action:(NRActionSheetActionBlock)cancelAction destructiveButtonTitle:(NSString *)destructiveButtonTitle action:(NRActionSheetActionBlock)destructiveAction otherButtonTitle:(NSString *)otherButtonTitle action:(NRActionSheetActionBlock)otherAction;
{
	self = [self initWithTitle:title delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitle, nil];
	if (cancelAction != nil)
		[self nr_setAction:cancelAction forButtonAtIndex:self.cancelButtonIndex];
	if (destructiveAction != nil)
		[self nr_setAction:destructiveAction forButtonAtIndex:self.destructiveButtonIndex];
	if (otherAction != nil)
		[self nr_setAction:otherAction forButtonAtIndex:self.firstOtherButtonIndex];
	return self;
}

- (NSInteger)nr_addButtonWithTitle:(NSString *)title action:(NRActionSheetActionBlock)action
{
	NSUInteger buttonIndex = [self addButtonWithTitle:title];
	[self nr_setAction:action forButtonAtIndex:buttonIndex];
	return buttonIndex;
}

- (void)nr_setAction:(NRActionSheetActionBlock)action forButtonAtIndex:(NSUInteger)buttonIndex
{
	NRActionSheetTrampoline *trampoline = self.delegate;
	if (trampoline == nil) {
		trampoline = [[NRActionSheetTrampoline alloc] init];
		self.delegate = trampoline;
		[self nr_addObject:trampoline forKey:NRActionSheetAdditionsCompletionBlocksKey];
	} else if (! [trampoline isKindOfClass:[NRActionSheetTrampoline class]]) {
		NSLog(@"could not set action: other delegate already set");
		return;
	}

	if (action == NULL)
		[trampoline.actions removeObjectForKey:@(buttonIndex)];
	else
		[trampoline.actions setObject:[action copy] forKey:@(buttonIndex)];
}

@end
