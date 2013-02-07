//
//  NRLogger.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-02-07.
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NRLogger : NSObject

+ (instancetype)sharedLogger;

@property (nonatomic) BOOL redirectStderr;

- (void)logAppInfo;

@end
