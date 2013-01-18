//
//  NRAlertView.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRFoundation.h"

static NSString *NRAlertViewCompletionBlocksKey = @"NRAlertViewCompletionBlocksKey";

@interface NRAlertViewTrampoline : NSObject <UIAlertViewDelegate>
@property (nonatomic, retain) NSMutableDictionary *actions;
@end

@implementation NRAlertViewTrampoline
@synthesize actions = _actions;

- (NSMutableDictionary *)actions
{
	if (_actions == nil)
		_actions = [NSMutableDictionary dictionary];
	return _actions;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// Added a button without block action?
	if ((NSInteger)[self.actions count] <= buttonIndex)
		return;

	NRAlertViewAction action = [self.actions objectForKey:@(buttonIndex)];
	if (action != nil)
		action(alertView, buttonIndex);
	alertView.delegate = nil;
	[alertView nr_removeObjectsForKey:NRAlertViewCompletionBlocksKey];
}

@end



@implementation UIAlertView (NRAlertView)

- (id)nr_initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle action:(NRAlertViewAction)cancelAction otherButtonTitle:(NSString *)otherButtonTitle action:(NRAlertViewAction)otherAction
{
	self = [self initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
	if (cancelAction != nil)
		[self nr_setAction:cancelAction forButtonAtIndex:self.cancelButtonIndex];
	if (otherAction != nil)
		[self nr_setAction:otherAction forButtonAtIndex:self.firstOtherButtonIndex];
	return self;
}

- (NSInteger)nr_addButtonWithTitle:(NSString *)title action:(NRAlertViewAction)action
{
	NSUInteger buttonIndex = [self addButtonWithTitle:title];
	[self nr_setAction:action forButtonAtIndex:buttonIndex];
	return buttonIndex;
}

- (void)nr_setAction:(NRAlertViewAction)action forButtonAtIndex:(NSUInteger)buttonIndex
{
	NRAlertViewTrampoline *trampoline = self.delegate;
	if (trampoline == nil) {
		trampoline = [[NRAlertViewTrampoline alloc] init];
		self.delegate = trampoline;
		[self nr_addObject:trampoline forKey:NRAlertViewCompletionBlocksKey];
	} else if (! [trampoline isKindOfClass:[NRAlertViewTrampoline class]]) {
		NSLog(@"could not set action: other delegate already set");
		return;
	}

	if (action == NULL)
		[trampoline.actions removeObjectForKey:@(buttonIndex)];
	else
		[trampoline.actions setObject:[action copy] forKey:@(buttonIndex)];
}

@end
