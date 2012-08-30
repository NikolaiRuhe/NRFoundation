//
//  NRGestureRecognizerAdditions.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRFoundation.h"


static NSString *NRGestureRecognizerAdditionsBlockActionKey = @"NRGestureRecognizerAdditionsBlockActionKey";
static NSString *NRAlertViewAdditionsShouldBeginBlockKey = @"NRAlertViewAdditionsShouldBeginBlockKey";

@interface NRGestureRecognizerTrampoline : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, copy) NRGestureRecognizerBlockAction blockAction;
@property (nonatomic, copy) NRGestureRecognizerShouldBeginBlock shouldBeginBlock;
@end

@implementation NRGestureRecognizerTrampoline
@synthesize blockAction = _blockAction;
@synthesize shouldBeginBlock = _shouldBeginBlock;

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
	self.blockAction(gestureRecognizer);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return self.shouldBeginBlock(gestureRecognizer);
}
@end



@implementation UIGestureRecognizer (NRGestureRecognizerAdditions)

- (id)nr_initWithBlockAction:(NRGestureRecognizerBlockAction)blockAction
{
	self = [self init];
	[self nr_addBlockAction:blockAction];
	return self;
}

- (void)nr_addBlockAction:(NRGestureRecognizerBlockAction)blockAction
{
	if (blockAction == nil) {
		NSLog(@"could not add block action: block is nil");
		return;
	}

	NRGestureRecognizerTrampoline *trampoline = [[NRGestureRecognizerTrampoline alloc] init];
	trampoline.blockAction = blockAction;
	[self addTarget:trampoline action:@selector(handleGesture:)];
	[self nr_addObject:trampoline forKey:NRGestureRecognizerAdditionsBlockActionKey];
}

- (void)nr_removeBlockActions
{
	for (NRGestureRecognizerTrampoline *trampoline in [self nr_objectsForKey:NRGestureRecognizerAdditionsBlockActionKey])
		[self removeTarget:trampoline action:@selector(handleGesture:)];
	[self nr_removeObjectsForKey:NRGestureRecognizerAdditionsBlockActionKey];
}

- (void)nr_setShouldBeginBlock:(NRGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
	if (self.delegate != nil && ! [self.delegate isKindOfClass:[NRGestureRecognizerTrampoline class]]) {
		NSLog(@"could not set should-begin block: other delegate already set");
		return;
	}

	[self nr_removeObjectsForKey:NRAlertViewAdditionsShouldBeginBlockKey];
	if (shouldBeginBlock == nil) {
		self.delegate = nil;
		return;
	}

	NRGestureRecognizerTrampoline *trampoline = [[NRGestureRecognizerTrampoline alloc] init];
	trampoline.shouldBeginBlock = shouldBeginBlock;
	self.delegate = trampoline;
	[self nr_addObject:trampoline forKey:NRAlertViewAdditionsShouldBeginBlockKey];
}

@end
