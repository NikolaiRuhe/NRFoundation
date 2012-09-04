//
//  NRGestureViewController.m
//  NRFoundationDemo
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRGestureViewController.h"
#import "NRFoundation.h"



@implementation NRGestureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] nr_initWithAction:^(UIGestureRecognizer *gestureRecognizer) {
		UILabel *dot = [[UILabel alloc] initWithFrame:(CGRect){.size = {32, 32}}];
		dot.center = [gestureRecognizer locationInView:gestureRecognizer.view];
		dot.backgroundColor = [UIColor colorWithWhite:0 alpha:.1f];
		dot.text = @"NR";
		dot.textColor = [UIColor colorWithWhite:0 alpha:.25f];
		dot.textAlignment = UITextAlignmentCenter;
		[gestureRecognizer.view addSubview:dot];
	}];
	[gestureRecognizer nr_setShouldBeginBlock:^BOOL(UIGestureRecognizer *gestureRecognizer) {
		CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
		UIView *hitView = [gestureRecognizer.view hitTest:p withEvent:nil];
		return hitView == gestureRecognizer.view || hitView.tag == 123;
	}];
	[self.view addGestureRecognizer:gestureRecognizer];
}

@end
