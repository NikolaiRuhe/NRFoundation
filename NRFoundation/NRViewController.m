//
//  NRViewController.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-12-04.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRViewController.h"
#import <objc/runtime.h>



static void NRSwizzleObject(id object);

@interface NRSegueTrampoline : NSObject
@property (nonatomic, strong) id sender;
@property (nonatomic, strong) void(^preparationBlock)(UIStoryboardSegue *segue);
@end

@implementation NRSegueTrampoline
@synthesize sender = _sender;
@synthesize preparationBlock = _preparationBlock;
@end


@implementation UIViewController (NRViewController)

- (void)nr_performSegueWithIdentifier:(NSString *)identifier sender:(id)sender prepare:(void(^)(UIStoryboardSegue *segue))preparationBlock
{
	NRSwizzleObject(self);
	NRSegueTrampoline *segueTrampoline = [[NRSegueTrampoline alloc] init];
	segueTrampoline.sender = sender;
	segueTrampoline.preparationBlock = preparationBlock;
	[self performSegueWithIdentifier:identifier sender:segueTrampoline];
}

static int coverViewAssociatedObjectKey;

- (void)nr_coverUsingColor:(UIColor *)color animated:(BOOL)animated
{
	if (! [self isViewLoaded])
		return;

	[self.view endEditing:YES];
	self.view.userInteractionEnabled = NO;

	UIView *coverView = objc_getAssociatedObject(self, &coverViewAssociatedObjectKey);
	if (coverView != nil)
		return;

	coverView = [[UIView alloc] initWithFrame:self.view.bounds];
	coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	coverView.backgroundColor = color;
	[self.view addSubview:coverView];
	objc_setAssociatedObject(self, &coverViewAssociatedObjectKey, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	if (! animated)
		return;

	coverView.alpha = 0;
	[UIView animateWithDuration:.35
					 animations:^{
						 coverView.alpha = 1;
					 }];
}

- (void)nr_removeCoverAnimated:(BOOL)animated
{
	if ([self isViewLoaded])
		self.view.userInteractionEnabled = YES;

	UIView *coverView = objc_getAssociatedObject(self, &coverViewAssociatedObjectKey);
	if (coverView == nil)
		return;

	objc_setAssociatedObject(self, &coverViewAssociatedObjectKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	if (! animated) {
		[coverView removeFromSuperview];
		return;
	}

	[UIView animateWithDuration:.35
					 animations:^{
						 coverView.alpha = 0;
					 }
					 completion:^(BOOL finished) {
						 [coverView removeFromSuperview];
					 }];
}

@end



static CFMutableSetRef swizzledSubclasses;
static CFMutableDictionaryRef swizzledSubclassForSuperclass;

static Class ScanSwizzledSubclass(id obj)
{
	Class class = object_getClass(obj);
	while(class && ! [(__bridge NSMutableSet *)swizzledSubclasses containsObject:class])
		class = class_getSuperclass(class);
	return class;
}

static Class CustomSubclassClassForCoder(id self, SEL _cmd)
{
	Class class = ScanSwizzledSubclass(self);
	Class superclass = class_getSuperclass(class);
	IMP superClassForCoder = class_getMethodImplementation(superclass, @selector(classForCoder));
	Class classForCoder = ((id (*)(id, SEL))superClassForCoder)(self, _cmd);
	if(classForCoder == class)
		classForCoder = superclass;
	return classForCoder;
}

static void CustomSubclassPrepareForSegueSender(id self, SEL _cmd, UIStoryboardSegue *segue, id sender)
{
	if ([sender isKindOfClass:[NRSegueTrampoline class]]) {
		((NRSegueTrampoline *)sender).preparationBlock(segue);
		return;
	}

	Class class = ScanSwizzledSubclass(self);
	Class superclass = class_getSuperclass(class);
	IMP superPrepareForSegueSender = class_getMethodImplementation(superclass, @selector(prepareForSegue:sender:));
	((id (*)(id, SEL, UIStoryboardSegue *, id))superPrepareForSegueSender)(self, _cmd, segue, sender);
}

static Class CreateCustomSubclass(Class class)
{
	NSString *newName = [NSString stringWithFormat:@"%s_NRFoundationSubclass", class_getName(class)];
	const char *newNameC = [newName UTF8String];

	Class subclass = objc_allocateClassPair(class, newNameC, 0);

	Method prepareForSegue_Sender = class_getInstanceMethod(class, @selector(prepareForSegue:sender:));
	class_addMethod(subclass, @selector(prepareForSegue:sender:), (IMP)CustomSubclassPrepareForSegueSender, method_getTypeEncoding(prepareForSegue_Sender));

	Method classForCoder = class_getInstanceMethod(class, @selector(classForCoder));
	class_addMethod(subclass, @selector(classForCoder), (IMP)CustomSubclassClassForCoder, method_getTypeEncoding(classForCoder));

	objc_registerClassPair(subclass);

	return subclass;
}

static void NRSwizzleObject(id object)
{
	if (ScanSwizzledSubclass(object) != nil)
		return;

	Class class = object_getClass(object);
	Class swizzledSubclass = nil;
	if (swizzledSubclassForSuperclass != NULL)
		swizzledSubclass = CFDictionaryGetValue(swizzledSubclassForSuperclass, (const void *)class);

	if(swizzledSubclass == nil) {
		swizzledSubclass = CreateCustomSubclass(class);

		if (swizzledSubclassForSuperclass == NULL)
			swizzledSubclassForSuperclass = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
		CFDictionarySetValue(swizzledSubclassForSuperclass, (const void *)class, (const void *)swizzledSubclass);

		if (swizzledSubclasses == NULL)
			swizzledSubclasses = CFSetCreateMutable(NULL, 0, NULL);
		CFSetSetValue(swizzledSubclasses, (const void *)swizzledSubclass);
		[(__bridge NSMutableSet *)swizzledSubclasses addObject:swizzledSubclass];
	}

	// only set the class if the current one is its superclass
	// otherwise it's possible that it returns something farther up in the hierarchy
	// and so there's no need to set it then
	if(class_getSuperclass(swizzledSubclass) == class)
		object_setClass(object, swizzledSubclass);
}
