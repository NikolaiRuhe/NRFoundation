//
//  NRDigest.m
//  NRFoundation
//
//  Created by Nikolai Ruhe on 2013-11-28.
//  Copyright (c) 2012 Nikolai Ruhe. All rights reserved.
//

#import "NRDigest.h"
#import <CommonCrypto/CommonDigest.h>

// NOTE: consider support of more digest algorithms:
// - other md* and sha* variants.
// - CityHash http://en.wikipedia.org/wiki/CityHash
// - MurmurHash http://en.wikipedia.org/wiki/MurmurHash
// - SpookyHash http://www.burtleburtle.net/bob/hash/spooky.html
// we should evaluate some more algorithms regarding performance


@implementation NRDigest

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initForSubclasses
{
	return [super init];
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (BOOL)isEqualToDigest:(NRDigest *)otherDigest
{
	return otherDigest == self;
}

- (void)updateMutableDigest:(NRMutableDigest *)digest
{
	[[self copy] updateMutableDigest:digest];
}

- (NSString *)description
{
	return [[self copy] description];
}

@end


@interface NRConstantDigest : NRDigest
@end


@implementation NRConstantDigest
{
	unsigned char _md5[CC_MD5_DIGEST_LENGTH];
}

- (id)initWithState:(CC_MD5_CTX)md5State
{
	self = [self initForSubclasses];
	if (self != nil) {
		CC_MD5_Final(_md5, &md5State);
	}
	return self;
}

- (BOOL)isEqualToDigest:(NRDigest *)otherDigest
{
	if (otherDigest == self)
		return YES;

	otherDigest = [otherDigest copy];

	return memcmp(&_md5, &(((NRConstantDigest *)otherDigest)->_md5), sizeof(_md5)) == 0;
}

- (NSUInteger)hash
{
	NSUInteger hashValue;
	memcpy(&hashValue, &_md5, sizeof(hashValue));
	return hashValue;
}

- (BOOL)isEqual:(id)other
{
	if (other == self)
		return YES;
	if (! [other isKindOfClass:[NRDigest class]])
		return NO;
	return [self isEqualToDigest:other];
}

- (void)updateMutableDigest:(NRMutableDigest *)digest
{
	[digest updateWithBytes:_md5 length:sizeof(_md5)];
}

- (NSString *)description
{
	static const char *hexDigits = "0123456789abcdef";
	char hex[33];
	char *ptr = hex;
	for (int i = 0; i < 16; ++i) {
		unsigned char v = _md5[i];
		*ptr++ = hexDigits[v >> 4];
		*ptr++ = hexDigits[v & 0x0f];
	}
	*ptr = 0;

	return [NSString stringWithUTF8String:hex];
}

@end


@implementation NRMutableDigest
{
	CC_MD5_CTX _md5State;
	NRConstantDigest *_currentDigest;
}

+ (NRMutableDigest *)digest
{
	return [[self alloc] init];
}

- (id)init
{
	self = [self initForSubclasses];
	if (self != nil) {
		CC_MD5_Init(&_md5State);
	}
	return self;
}

- (void)updateWithBytes:(const void *)bytes length:(NSUInteger)length
{
	if (length == 0)
		return;

	_currentDigest = nil;
	CC_MD5_Update(&_md5State, bytes, length);
}

- (void)updateWithData:(NSData *)data
{
	[self updateWithBytes:[data bytes] length:[data length]];
}

- (void)updateWithString:(NSString *)string
{
	[self updateWithString:string normalize:YES];
}

- (void)updateWithString:(NSString *)string normalize:(BOOL)normalize
{
	if (string == nil)
		return;

	if (normalize)
		string = [string decomposedStringWithCanonicalMapping];

	const UniChar *characters = CFStringGetCharactersPtr((__bridge CFStringRef)string);

	if (characters == NULL) {
		[self updateWithData:[string dataUsingEncoding:NSUnicodeStringEncoding]];
	} else {
		[self updateWithBytes:characters length:CFStringGetLength((__bridge CFStringRef)string)];
	}
}

- (void)updateWithDigest:(NRDigest *)digest
{
	[digest updateMutableDigest:self];
}

- (id)copyWithZone:(NSZone *)zone
{
	if (_currentDigest == nil)
		_currentDigest = [[NRConstantDigest alloc] initWithState:_md5State];

	return _currentDigest;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
	NRMutableDigest *mutableCopy = [[[self class] alloc] init];
	memcpy(&(mutableCopy->_md5State), &_md5State, sizeof(_md5State));
	mutableCopy->_currentDigest = _currentDigest;

	return mutableCopy;
}

- (NSUInteger)hash
{
	return [[self copyWithZone:nil] hash];
}

@end
