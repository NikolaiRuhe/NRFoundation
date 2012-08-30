//
//  NRObjectAdditions.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2012-08-27.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (NRObjectAdditions)

- (void)nr_addObject:(id)object forKey:(NSString *)key;
- (NSArray *)nr_objectsForKey:(NSString *)key;
- (void)nr_removeObjectsForKey:(NSString *)key;

@end
