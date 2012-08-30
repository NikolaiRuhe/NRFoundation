//
//  NRUtilities.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-31.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>

// NR_CAST dynamically checks the type of the operand and returns the operand
// if it decends from type, nil otherwise.

#define NR_CAST(operand, type) (type *)([(type) isKindOfClass:[type class]] ? (type) : nil)
