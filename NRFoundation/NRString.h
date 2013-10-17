//
//  NRString.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-10-17.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NRString)

+ (NSString *)nr_makeUUID;

- (NSString *)nr_stringByAddingAllRequiredPercentEscapesUsingEncoding:(NSStringEncoding)encoding;

@end
