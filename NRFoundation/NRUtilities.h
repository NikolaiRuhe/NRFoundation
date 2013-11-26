//
//  NRUtilities.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-31.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSLocale (NRLocale)

+ (NSString *)nr_POSIXLocaleIdentifier;
+ (instancetype)nr_POSIXLocale;

@end