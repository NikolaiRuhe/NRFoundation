//
//  NRDistanceFormatter.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2014-01-23.
//  Copyright (c) 2014 Nikolai Ruhe. All rights reserved.
//

#import "NRDistanceFormatter.h"
#import <CoreLocation/CoreLocation.h>


@implementation NRDistanceFormatter

@synthesize locale = _locale;
@synthesize numberFormatter = _numberFormatter;

- (NSLocale *)locale
{
	if (_locale == nil)
		_locale = [NSLocale currentLocale];
	return _locale;
}

- (NSNumberFormatter *)numberFormatter
{
	if (_numberFormatter == nil) {
		_numberFormatter = [[NSNumberFormatter alloc] init];
		[_numberFormatter setLocale:self.locale];
		[_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[_numberFormatter setMaximumSignificantDigits:2];
		[_numberFormatter setUsesSignificantDigits:YES];
	}
	return _numberFormatter;
}

- (NSString *)stringForObjectValue:(id)obj
{
	CLLocationDistance meters = [obj doubleValue];

	BOOL metricSystem = [[[self locale] objectForKey:NSLocaleUsesMetricSystem] boolValue];

	if (metricSystem)
		return [self metricStringForMeters:meters];

	return [self imperialStringForMeters:meters];
}

- (NSString *)metricStringForMeters:(CLLocationDistance)meters
{
	if (meters < .01)
		return [NSString stringWithFormat:@"%@ mm", [self.numberFormatter stringFromNumber:@(meters * 1000)]];

	if (meters < 1)
		return [NSString stringWithFormat:@"%@ cm", [self.numberFormatter stringFromNumber:@(meters * 100)]];

	if (meters < 1000)
		return [NSString stringWithFormat:@"%@ m", [self.numberFormatter stringFromNumber:@(meters)]];

	if (meters < 149597870700)
		return [NSString stringWithFormat:@"%@ km", [self.numberFormatter stringFromNumber:@(meters * 0.001)]];

	return [NSString stringWithFormat:@"%@ au", [self.numberFormatter stringFromNumber:@(meters / 149597870700)]];
}

- (NSString *)imperialStringForMeters:(CLLocationDistance)meters
{
	CLLocationDistance inches = meters / 0.0254;
	if (inches < 12)
		return [NSString stringWithFormat:@"%@ in", [self.numberFormatter stringFromNumber:@(inches)]];

	CLLocationDistance feet  = meters / 0.3048;
	if (feet < 3)
		return [NSString stringWithFormat:@"%@ ft", [self.numberFormatter stringFromNumber:@(feet)]];

	CLLocationDistance yards = meters / 0.9144;
	if (yards < 1)
		return [NSString stringWithFormat:@"%@ yd", [self.numberFormatter stringFromNumber:@(yards)]];

	CLLocationDistance miles = meters / 1609.344;
	if (meters < 149597870700)
		return [NSString stringWithFormat:@"%@ mi", [self.numberFormatter stringFromNumber:@(miles)]];

	return [NSString stringWithFormat:@"%@ au", [self.numberFormatter stringFromNumber:@(meters / 149597870700)]];
}

- (BOOL)getObjectValue:(out id __autoreleasing *)obj forString:(NSString *)string errorDescription:(out NSString * __autoreleasing *)error
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@end
