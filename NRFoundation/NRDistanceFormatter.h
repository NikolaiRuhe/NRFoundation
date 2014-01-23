//
//  NRDistanceFormatter.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2014-01-23.
//  Copyright (c) 2014 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NRDistanceFormatter : NSFormatter

@property (nonatomic, retain) NSLocale *locale;
@property (nonatomic, retain) NSNumberFormatter *numberFormatter;

@end
