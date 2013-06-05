//
//  NRPrefix.h
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-05-27
//  Copyright (c) 2013 Nikolai Ruhe. All rights reserved.
//

// we use an include guard here to be able to import this header
// using #import <NRFoundation/NRPrefix.h> and then
// #import "NRPrefix.h" without problems.

#ifndef NR_PREFIX_H_INCLUDE_GUARD
#define NR_PREFIX_H_INCLUDE_GUARD



#include <Availability.h>

#include <CoreFoundation/CoreFoundation.h>

#ifdef __OBJC__
	#import <Foundation/Foundation.h>
	#import <UIKit/UIKit.h>
	#import <QuartzCore/QuartzCore.h>
	#import <ImageIO/ImageIO.h>
#endif

#ifdef UNIT_TESTS
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
	#import <SenTestingKit/SenTestingKit.h>
	#pragma clang diagnostic pop
#endif


// try to include NRFoundation.h
#if defined(__has_include) && __OBJC__
	#if __has_include(<NRFoundation/NRFoundation.h>)
		#import <NRFoundation/NRFoundation.h>
	#elif __has_include("NRFoundation.h")
		#import "NRFoundation.h"
	#endif
#endif

// make sure either DEBUG or NDEBUG ist set
#ifdef NDEBUG
	#ifdef DEBUG
		#error "Both DEBUG and NDEBUG are defined"
	#endif
#else
	#ifndef DEBUG
		#error "Neither DEBUG nor NDEBUG are defined"
	#endif
#endif

// if warnings are treated as errors by the compiler, make #warnings normal warnings again
#pragma clang diagnostic warning "-W#warnings"

#define NR_STR(X) #X

// These macros can be used to mark locations in code that need review.
// They can be switched on by setting NR_SHOW_MARKERS=1 which will make the
// compiler emit warnings.
#if defined(NR_SHOW_MARKERS) && NR_SHOW_MARKERS
	#define NR_TODO(...)  _Pragma(NR_STR(message "TODO: "  #__VA_ARGS__))
	#define NR_FIXME(...) _Pragma(NR_STR(message "FIXME: " #__VA_ARGS__))
	#define NR_NOTE(...)  _Pragma(NR_STR(message "NOTE: "  #__VA_ARGS__))
#else
	#define NR_TODO(...)
	#define NR_FIXME(...)
	#define NR_NOTE(...)
#endif

// some Objective-C helper macros
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
		return object;
	return nil;
}

#define NR_DYNAMIC_CAST(className, object) \
	((className *)NRDynamicCastHelper((object), [className class]))

static inline id NRAssertedCastHelper(id object, Class objcClass, const char *file, const char *function, NSInteger line, const char *argumentName, const char *typeName)  __attribute__ ((always_inline));
static inline id NRAssertedCastHelper(id object, Class objcClass, const char *file, const char *function, NSInteger line, const char *argumentName, const char *typeName)
{
	if ([object isKindOfClass:objcClass])
		return object;
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

#endif // NR_PREFIX_H_INCLUDE_GUARD
