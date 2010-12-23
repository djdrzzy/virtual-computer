/**
 * Copyright (c) 2010 Daniel Drzimotta (djdrzzy@gmail.com)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "VCInstructionDelegate.h"
#import "VCInstructionDelegateCache.h"
#import "VCInstructionNopDelegate.h"
#import "VCInstructionOutputDelegate.h"
#import <objc/objc-runtime.h>

@interface VCInstructionDelegateCache ()
@property (nonatomic, readwrite, retain) NSDictionary *cacheByOpcode;
@property (nonatomic, readwrite, retain) NSDictionary *cacheByTextualCode;
@end


@implementation VCInstructionDelegateCache

- (id) init {
	self = [super init];
	if (self != nil) {
		
		NSMutableDictionary *dictionaryOfInstructionsByOpcode = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *dictionaryOfInstructionsByTextualCode = [[NSMutableDictionary alloc] init];
		
		int numClasses;
		Class * classes = NULL;
		
		classes = NULL;
		numClasses = objc_getClassList(NULL, 0);
		
		if (numClasses > 0 )
		{
			classes = malloc(sizeof(Class) * numClasses);
			numClasses = objc_getClassList(classes, numClasses);
			
			
			for(int i = 0; i < numClasses; i++) {
				//NSLog(@"classes[i]: %@", classes[i]);
				if(class_conformsToProtocol(classes[i], @protocol(VCInstructionDelegate))) {
					
					id delegateToCache = [[classes[i] alloc] init];
					
					NSString *classKeyOpcode = [NSString stringWithFormat:@"%i", 
																			[delegateToCache instructionOperationCode]];
					
					NSString *classKeyTextualCode = [delegateToCache instructionTextualCode];
					
					NSAssert([dictionaryOfInstructionsByOpcode valueForKey:classKeyOpcode] == nil, @"Opcode collision!");
					NSAssert([dictionaryOfInstructionsByTextualCode valueForKey:classKeyTextualCode] == nil, @"Textual code collision!");
					
					[dictionaryOfInstructionsByOpcode setValue:delegateToCache forKey:classKeyOpcode];
					[dictionaryOfInstructionsByTextualCode setValue:delegateToCache forKey:classKeyTextualCode];
					
					[delegateToCache release];
				}
			}
			
			
			self.cacheByOpcode = dictionaryOfInstructionsByOpcode;
			self.cacheByTextualCode = dictionaryOfInstructionsByTextualCode;
			
			
			free(classes);
		}
		
		
		[dictionaryOfInstructionsByOpcode release];
		[dictionaryOfInstructionsByTextualCode release];
		
		
		
	}
	return self;
}

-(void) dealloc {
	self.cacheByOpcode = nil;
	self.cacheByTextualCode = nil;
	
	[super dealloc];
}

-(NSObject<VCInstructionDelegate>*) delegateForOpcode:(int)opcode {
	id delegateToReturn = nil;
	
	NSString *classKey = [NSString stringWithFormat:@"%i", opcode];
	
	delegateToReturn = [self.cacheByOpcode valueForKey:classKey];
	
	if (!delegateToReturn) {
		delegateToReturn = [[[VCInstructionNopDelegate alloc] init] autorelease];
	}
	
	return delegateToReturn;
}


-(NSObject<VCInstructionDelegate>*) delegateForTextualCode:(NSString*)textualCode {
	id delegateToReturn = nil;
	
	NSString *classKey = textualCode;
	
	delegateToReturn = [self.cacheByTextualCode valueForKey:classKey];
	
	if (!delegateToReturn) {
		delegateToReturn = [[[VCInstructionNopDelegate alloc] init] autorelease];
	}
	
	return delegateToReturn;	
}

@end
