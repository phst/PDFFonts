//
//  DocumentProcessor.m
//  PDFFonts
//
//  Created by Philipp Stephani on 20.12.09.
//  Copyright 2010, 2011 Philipp Stephani. All rights reserved.
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

#import "DocumentProcessor.h"
#import "FontProperties.h"


static void processFontDictionary(const char *key, CGPDFObjectRef object, void *info);


@implementation DocumentProcessor

- (id)initWithURL:(NSURL *)aURL fontList:(FontList *)aResult {
	if ((self = [super init])) {
		url = aURL;
		result = aResult;
	}
	return self;
}

- (void)processDocument {
	CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)url);
	if (document) {
		for (size_t index = 1, count = CGPDFDocumentGetNumberOfPages(document); index <= count; ++index) {
			CGPDFPageRef page = CGPDFDocumentGetPage(document, index);
			if (page) {
				[self processPage:page];
			}
		}		
		CGPDFDocumentRelease(document);
	} else {
		NSLog(@"Cannot process document with URL %@", url);
	}
}

- (void)processPage:(CGPDFPageRef)page {
	CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(page);
	CGPDFDictionaryRef resourceDictionary = nil;
	if (CGPDFDictionaryGetDictionary(pageDictionary, "Resources", &resourceDictionary)) {
		CGPDFDictionaryRef fontResourceDictionary = nil;
		if (CGPDFDictionaryGetDictionary(resourceDictionary, "Font", &fontResourceDictionary)) {
			CGPDFDictionaryApplyFunction(fontResourceDictionary, processFontDictionary, self);
		}
	}
}

- (void)processFontDictionary:(CGPDFDictionaryRef)fontDictionary {
	NSString *type = [DocumentProcessor nameFromDictionary:fontDictionary key:"Subtype"];
	NSString *name = [DocumentProcessor nameFromDictionary:fontDictionary key:"BaseFont"];
	FontProperties *properties = [[FontProperties alloc] initWithType:type name:name];
	[result addFontProperties:properties];
}

+ (NSString *)nameFromDictionary:(CGPDFDictionaryRef)dictionary key:(const char*)key {
	const char *result = nil;
	if (CGPDFDictionaryGetName(dictionary, key, &result)) {
		return [NSString stringWithUTF8String:result];
	} else {
		return nil;
	}
}

@end


static void processFontDictionary(const char *key, CGPDFObjectRef object, void *info) {
	CGPDFDictionaryRef fontDictionary = NULL;
	if (CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &fontDictionary)) {
		id documentProcessor = (id)info;
		[documentProcessor processFontDictionary:fontDictionary];
	} else {
		NSLog(@"Font resource item does not point to a dictionary");
	}

}

