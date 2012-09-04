//
//  NRGestureRecognizer.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRFoundation.h"


static NSString *NRGestureRecognizerActionKey = @"NRGestureRecognizerActionKey";
static NSString *NRGestureRecognizerShouldBeginBlockKey = @"NRGestureRecognizerShouldBeginBlockKey";

@interface NRGestureRecognizerTrampoline : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, copy) NRGestureRecognizerAction action;
@property (nonatomic, copy) NRGestureRecognizerShouldBeginBlock shouldBeginBlock;
@end

@implementation NRGestureRecognizerTrampoline
@synthesize action = _action;
@synthesize shouldBeginBlock = _shouldBeginBlock;

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
	self.action(gestureRecognizer);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	return self.shouldBeginBlock(gestureRecognizer);
}
@end



@implementation UIGestureRecognizer (NRGestureRecognizer)

- (id)nr_initWithAction:(NRGestureRecognizerAction)action
{
	self = [self init];
	[self nr_addAction:action];
	return self;
}

- (void)nr_addAction:(NRGestureRecognizerAction)action
{
	if (action == nil) {
		NSLog(@"could not add block action: block is nil");
		return;
	}

	NRGestureRecognizerTrampoline *trampoline = [[NRGestureRecognizerTrampoline alloc] init];
	trampoline.action = action;
	[self addTarget:trampoline action:@selector(handleGesture:)];
	[self nr_addObject:trampoline forKey:NRGestureRecognizerActionKey];
}

- (void)nr_removeAllBlockActions
{
	for (NRGestureRecognizerTrampoline *trampoline in [self nr_objectsForKey:NRGestureRecognizerActionKey])
		[self removeTarget:trampoline action:@selector(handleGesture:)];
	[self nr_removeObjectsForKey:NRGestureRecognizerActionKey];
}

- (void)nr_setShouldBeginBlock:(NRGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
	if (self.delegate != nil && ! [self.delegate isKindOfClass:[NRGestureRecognizerTrampoline class]]) {
		NSLog(@"could not set should-begin block: other delegate already set");
		return;
	}

	[self nr_removeObjectsForKey:NRGestureRecognizerShouldBeginBlockKey];
	if (shouldBeginBlock == nil) {
		self.delegate = nil;
		return;
	}

	NRGestureRecognizerTrampoline *trampoline = [[NRGestureRecognizerTrampoline alloc] init];
	trampoline.shouldBeginBlock = shouldBeginBlock;
	self.delegate = trampoline;
	[self nr_addObject:trampoline forKey:NRGestureRecognizerShouldBeginBlockKey];
}

@end
