//
//  NRViewController.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-12-04.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NRViewController)

- (void)nr_performSegueWithIdentifier:(NSString *)identifier sender:(id)sender prepare:(void(^)(UIStoryboardSegue *segue))preparationBlock;

- (void)nr_coverUsingColor:(UIColor *)color animated:(BOOL)animated;
- (void)nr_removeCoverAnimated:(BOOL)animated;

@end
