//
//  NRPrefix.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-05-27
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

#ifndef NR_PREFIX_H_INCLUDED
#define NR_PREFIX_H_INCLUDED

// we use an include guard here to be able to import this header
// using #import <NRFoundation/NRPrefix.h> and then
// #import "Prefix.h" without problems.

#include <Availability.h>
#include <CoreFoundation/CoreFoundation.h>

#ifdef __OBJC__
	#import <Foundation/Foundation.h>
	#import <UIKit/UIKit.h>
	#import <QuartzCore/QuartzCore.h>
	#import <ImageIO/ImageIO.h>
#endif

#ifdef UNIT_TESTS
	#import <SenTestingKit/SenTestingKit.h>
#endif

#if defined(__has_include)
	#if __OBJC__
		#if __has_include(<NRFoundation/NRFoundation.h>)
			#import <NRFoundation/NRFoundation.h>
		#elif __has_include("NRFoundation.h")
			#import "NRFoundation.h"
		#endif
		#if __has_include("project.h")
			#import "project.h"
		#endif
		#if __has_include("project-config.h")
			#import "project-config.h"
		#endif
	#endif
#endif

#ifdef NDEBUG
	#ifdef DEBUG
		#error "Both DEBUG and NDEBUG are defined"
	#endif
#else
	#ifndef DEBUG
		#error "Neither DEBUG nor NDEBUG are defined"
	#endif
#endif

#if __OBJC__

// checks for equal objects or both parameters nil.
static inline BOOL NRObjectEqualObject(id a, id b)
{
	return a == b || [a isEqual:b];
}

// checks for equal strings, considers nil == empty string.
static inline BOOL NRStringEqualString(NSString *a, NSString *b)
{
	return a == b || [a length] + [b length] == 0 || [a isEqualToString:b];
}

#define NR_WEAK(variable)       typeof(variable) __weak              weak_       ## variable = (variable)
#define NR_UNRETAINED(variable) typeof(variable) __unsafe_unretained unretained_ ## variable = (variable)

static inline id NRDynamicCastHelper(id object, Class objcClass) __attribute__ ((always_inline));
static inline id NRDynamicCastHelper(id object, Class objcClass)
{
	if ([object isKindOfClass:objcClass])
		return objcClass;
	return nil;
}

#define NR_DYNAMIC_CAST(className, object) \
	((className *)NRDynamicCastHelper((object), [className class]))

static inline id NRAssertedCastHelper(id object, Class objcClass, const char *file, const char *function, NSInteger line, const char *argumentName, const char *typeName)  __attribute__ ((always_inline));
static inline id NRAssertedCastHelper(id object, Class objcClass, const char *file, const char *function, NSInteger line, const char *argumentName, const char *typeName)
{
	if ([object isKindOfClass:objcClass])
		return objcClass;
	[[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithUTF8String:function]
															file:[NSString stringWithUTF8String:file]
													  lineNumber:line
													 description:@"NR_ASSERTED_CAST: \"%s\" not of expected type \"%s\"", argumentName, typeName];
	return nil;
}

#ifndef NDEBUG
#define NR_ASSERTED_CAST(className, object) \
	((className *)NRAssertedCastHelper((object), [className class], __FILE__, __PRETTY_FUNCTION__, __LINE__, #object, #className))
#else
#define NR_ASSERTED_CAST(className, object) \
	((className *)(object))
#endif

#endif

#endif // NR_PREFIX_H_INCLUDED
