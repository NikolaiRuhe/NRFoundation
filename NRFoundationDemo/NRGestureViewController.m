//
//  NRGestureViewController.m
//  NRFoundationDemo
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRGestureViewController.h"
#import <QuartzCore/QuartzCore.h>



@implementation NRGestureViewController

@synthesize blockView = _blockView;

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.blockView.layer.cornerRadius = 30;

	[self.blockView addGestureRecognizer:[[UITapGestureRecognizer alloc] nr_initWithAction:^(UIGestureRecognizer *gestureRecognizer) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
		animation.fromValue = @0;
		animation.toValue = @(M_PI * 2);
		animation.duration = .5;
		[gestureRecognizer.view.layer addAnimation:animation forKey:@"rotation"];
	}]];

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] nr_initWithAction:^(UIGestureRecognizer *gestureRecognizer) {
		UILabel *dot = [[UILabel alloc] initWithFrame:(CGRect){.size = {44, 44}}];
		dot.layer.cornerRadius = 22;
		dot.center = [gestureRecognizer locationInView:gestureRecognizer.view];
		CGFloat hue = .001f * (random() % 1000);
		dot.backgroundColor = [UIColor colorWithHue:hue saturation:.3 brightness:1 alpha:1];
		dot.layer.borderWidth = 2;
		dot.layer.borderColor = [UIColor colorWithHue:hue saturation:.5 brightness:1 alpha:1].CGColor;
		dot.text = [NSString stringWithFormat:@"%d", [self.view.subviews count]];
		dot.textColor = [UIColor colorWithHue:hue saturation:1 brightness:.5 alpha:1];
		dot.textAlignment = UITextAlignmentCenter;
		[gestureRecognizer.view insertSubview:dot belowSubview:self.blockView];
		if ([[self.view subviews] count] > 30) {
			CGPoint center = { 0.5f * self.view.bounds.size.width, 0.5f * self.view.bounds.size.height};
			[UIView animateWithDuration:1 animations:^{
				for (UIView *subview in [self.view subviews]) {
					if (subview == self.blockView)
						continue;
					CGFloat a = atan2f(subview.center.y - center.y, subview.center.x - center.x);
					subview.center = (CGPoint){center.x + center.x * 2 * cos(a), center.y + center.y * 2 * sin(a)};
				}
				self.view.userInteractionEnabled = NO;
			} completion:^(BOOL finished) {
				for (UIView *subview in [[self.view subviews] copy]) {
					if (subview == self.blockView)
						continue;
					[subview removeFromSuperview];
				}
				self.view.userInteractionEnabled = YES;
			}];
		}
	}];
	[gestureRecognizer nr_setShouldBeginBlock:^BOOL(UIGestureRecognizer *gestureRecognizer) {
		CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
		UIView *hitView = [gestureRecognizer.view hitTest:p withEvent:nil];
		return hitView == gestureRecognizer.view || hitView.tag == 123;
	}];
	[self.view addGestureRecognizer:gestureRecognizer];
}

@end
