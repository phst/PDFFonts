//
//  Application.m
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

#import "Application.h"

#import "FontList.h"
#import "DocumentProcessor.h"


@implementation Application

- (id)init {
	if (self = [super init]) {
		merged = NO;
		pretty = YES;
		sorted = YES;
		autoHeader = YES;
		files = [NSMutableArray array];
		[self processArguments];
	}
	return self;
}

- (void)processArguments {
	NSProcessInfo *processInfo = [NSProcessInfo processInfo];
	NSArray *arguments = [processInfo arguments];
	BOOL processOptions = YES;
	for (NSUInteger index = 1, count = [arguments count]; index < count; ++index) {
		NSString *argument = [arguments objectAtIndex:index];
		if (processOptions && [argument hasPrefix:@"-"]) {
			if ([argument isEqualToString:@"--"]) {
				processOptions = NO;
			} else {
				[self processOptionArgument:argument];
			}
		} else {
			NSURL *url = [NSURL fileURLWithPath:argument];
			[files addObject:url];
		}
	}
	if (autoHeader) {
		header = [files count] > 1;
	}
}

- (void)processOptionArgument:(NSString *)argument {
	for (NSUInteger index = 1, length = [argument length]; index < length; ++index) {
		unichar character = [argument characterAtIndex:index];
		[self processOption:character];
	}
}

- (void)processOption:(unichar)option {
	switch (option) {
		case 'm':
			merged = YES;
			sorted = YES;
			header = NO;
			autoHeader = NO;
			break;
		case 'M':
			merged = NO;
			break;
		case 'R':
			pretty = YES;
			break;
		case 'r':
			pretty = NO;
			break;
		case 'U':
			sorted = YES;
			break;
		case 'u':
			sorted = NO;
			merged = NO;
			break;
		case 'n':
			header = YES;
			autoHeader = NO;
			merged = NO;
			break;
		case 'N':
			header = NO;
			autoHeader = NO;
			break;
		case 'a':
			autoHeader = YES;
			break;
		default:
			NSLog(@"Unknown option -%C", option);
			break;
	}
}

- (void)processDocuments {
	if (merged) {
		[self processDocumentsMerged];
	} else {
		[self processDocumentsUnmerged];
	}
}

- (void)processDocumentsMerged {
	FontList *result = [[FontList alloc] initWithPretty:pretty sorted:YES];
	for (NSURL *url in files) {
		DocumentProcessor *documentProcessor = [[DocumentProcessor alloc] initWithURL:url fontList:result];
		[documentProcessor processDocument];
	}
	[result print];
}

- (void)processDocumentsUnmerged {
	BOOL first = YES;
	for (NSURL *url in files) {
		if (header) {
			if (!first) printf("\n");
			first = NO;
			printf("%s:\n", [[url relativeString] UTF8String]);
		}
		FontList *result = [[FontList alloc] initWithPretty:pretty sorted:sorted];
		DocumentProcessor *documentProcessor = [[DocumentProcessor alloc] initWithURL:url fontList:result];
		[documentProcessor processDocument];
		[result print];
	}
}

@end
