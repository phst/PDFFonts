//
//  FontProperties.m
//  PDFFonts
//
//  Created by Philipp Stephani on 20.12.09.
//  Copyright 2010 Philipp Stephani. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//    1. Redistributions of source code must retain the above copyright notice, this list of
//       conditions and the following disclaimer.
//  
//    2. Redistributions in binary form must reproduce the above copyright notice, this list
//       of conditions and the following disclaimer in the documentation and/or other materials
//       provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY PHILIPP STEPHANI "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL PHILIPP STEPHANI OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Philipp Stephani.
//

#import "FontProperties.h"


@implementation FontProperties

- (id)initWithType:(NSString *)aType name:(NSString *)aName {
	if (self = [super init]) {
		type = aType;
		name = aName;
	}
	return self;
}

- (FontProperties *)prettyProperties {
	NSRange range = [name rangeOfString:@"+"];
	if (range.location != NSNotFound) {
		NSUInteger start = range.location + range.length;
		NSString *prettyName = [name substringFromIndex:start];
		return [[FontProperties alloc] initWithType:type name:prettyName];
	} else {
		return self;
	}
}

- (NSComparisonResult)nameCompare:(FontProperties *)other {
	return [name caseInsensitiveCompare:other->name];
}

- (BOOL)isEqual:(id)other {
	if (other == self) {
		return YES;
	} else if (!(other && [other isKindOfClass:[self class]])) {
		return NO;
	} else {
		return [self isEqualToFontProperties:other];
	}
}

- (BOOL)isEqualToFontProperties:(FontProperties *)other {
	return (self == other) || ([name isEqualToString:other->name] && [type isEqualToString:other->type]);
}

- (NSUInteger)hash {
	return [name hash] ^ [type hash];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ (%@)", name, type];
}

@end
