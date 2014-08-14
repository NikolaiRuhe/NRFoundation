//
//  NRMemoryLabel.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2014-08-14
//  Copyright (c) 2014 Nikolai Ruhe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NRMemoryLabel : UILabel

@property (nonatomic) NSTimeInterval updateInterval;
@property (nonatomic, readonly) NSUInteger residentSize;

- (void)presentInOverlayWindow;

@end
