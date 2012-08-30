//
//  NRDetailViewController.m
//  NRFoundationDemo
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRDetailViewController.h"
#import "NRFoundation.h"



@implementation NRDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] nr_initWithBlockAction:^(UIGestureRecognizer *gestureRecognizer) {
		UILabel *dot = [[UILabel alloc] initWithFrame:(CGRect){.size = {32, 32}}];
		dot.center = [gestureRecognizer locationInView:gestureRecognizer.view];
		dot.backgroundColor = [UIColor colorWithWhite:0 alpha:.1f];
		dot.text = @"NR";
		dot.textColor = [UIColor colorWithWhite:0 alpha:.25f];
		dot.textAlignment = UITextAlignmentCenter;
		[gestureRecognizer.view addSubview:dot];
	}]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
