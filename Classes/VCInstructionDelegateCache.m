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


/**
 * So this use to be a lot nicer and dynamic but unfortunately the way I was 
 * looking for classes using the runtime wasn't working so well when this was
 * being used by other projects as a static library. Less elegant but it works.
 *
 * The last commit that had that really nice approach was:
 * 4801754b11eca07b95bb264dc01159529dddcfe3
 */

#import "VCInstructionDelegate.h"
#import "VCInstructionDelegateCache.h"
#import <objc/objc-runtime.h>

#import "VCInstructionAddDelegate.h"
#import "VCInstructionAddImmediateDelegate.h"
#import "VCInstructionAndDelegate.h"
#import "VCInstructionAndImmediateDelegate.h"
#import "VCInstructionBranchGreaterEqualDelegate.h"
#import "VCInstructionBranchGreaterThanDelegate.h"
#import "VCInstructionBranchLessEqualDelegate.h"
#import "VCInstructionBranchLessThanDelegate.h"
#import "VCInstructionBranchOnEqualDelegate.h"
#import "VCInstructionBranchOnNotEqualDelegate.h"
#import "VCInstructionDivideDelegate.h"
#import "VCInstructionHaltDelegate.h"
#import "VCInstructionInputDelegate.h"
#import "VCInstructionJumpDelegate.h"
#import "VCInstructionJumpRegisterDelegate.h"
#import "VCInstructionLoadWordDelegate.h"
#import "VCInstructionLoadWordImmediateDelegate.h"
#import "VCInstructionMultiplyDelegate.h"
#import "VCInstructionNopDelegate.h"
#import "VCInstructionNotDelegate.h"
#import "VCInstructionOrDelegate.h"
#import "VCInstructionOrImmediateDelegate.h"
#import "VCInstructionOutputDelegate.h"
#import "VCInstructionSetOnLessThanDelegate.h"
#import "VCInstructionSetOnLessThanImmediateDelegate.h"
#import "VCInstructionShiftLeftLogicalDelegate.h"
#import "VCInstructionShiftRightLogicalDelegate.h"
#import "VCInstructionStoreWordDelegate.h"
#import "VCInstructionStoreWordImmediateDelegate.h"
#import "VCInstructionSubtractDelegate.h"
#import "VCInstructionSubtractImmediateDelegate.h"
#import "VCInstructionXorDelegate.h"

@interface VCInstructionDelegateCache ()
@property (nonatomic, readwrite, strong) NSDictionary *cacheByOpcode;
@property (nonatomic, readwrite, strong) NSDictionary *cacheByTextualCode;
@end


@implementation VCInstructionDelegateCache

- (id) init {
	self = [super init];
	if (self != nil) {
		
		NSMutableDictionary *dictionaryOfInstructionsByOpcode = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *dictionaryOfInstructionsByTextualCode = [[NSMutableDictionary alloc] init];
		
		NSArray *instructionDelegates = 
		@[VCInstructionAddDelegate.class,
		 VCInstructionAddImmediateDelegate.class,
		 VCInstructionAndDelegate.class,
		 VCInstructionAndImmediateDelegate.class,
		 VCInstructionBranchGreaterEqualDelegate.class,
		 VCInstructionBranchGreaterThanDelegate.class,
		 VCInstructionBranchLessEqualDelegate.class,
		 VCInstructionBranchLessThanDelegate.class,
		 VCInstructionBranchOnEqualDelegate.class,
		 VCInstructionBranchOnNotEqualDelegate.class,
		 VCInstructionDivideDelegate.class,
		 VCInstructionHaltDelegate.class,
		 VCInstructionInputDelegate.class,
		 VCInstructionJumpDelegate.class,
		 VCInstructionJumpRegisterDelegate.class,
		 VCInstructionLoadWordDelegate.class,
		 VCInstructionLoadWordImmediateDelegate.class,
		 VCInstructionMultiplyDelegate.class,
		 VCInstructionNopDelegate.class,
		 VCInstructionNotDelegate.class,
		 VCInstructionOrDelegate.class,
		 VCInstructionOrImmediateDelegate.class,
		 VCInstructionOutputDelegate.class,
		 VCInstructionSetOnLessThanDelegate.class,
		 VCInstructionSetOnLessThanImmediateDelegate.class,
		 VCInstructionShiftLeftLogicalDelegate.class,
		 VCInstructionShiftRightLogicalDelegate.class,
		 VCInstructionStoreWordDelegate.class,
		 VCInstructionStoreWordImmediateDelegate.class,
		 VCInstructionSubtractDelegate.class,
		 VCInstructionSubtractImmediateDelegate.class,
		 VCInstructionXorDelegate.class];
		
		for(NSUInteger i = 0; i < instructionDelegates.count; i++) {
			NSAssert(class_conformsToProtocol(instructionDelegates[i], @protocol(VCInstructionDelegate)),
							 @"The encountered class does not conform to the proper protocol!");
			
			id delegateToCache = [[instructionDelegates[i] alloc] init];
			
			NSString *classKeyOpcode = [NSString stringWithFormat:@"%i", 
																	[delegateToCache instructionOperationCode]];
			
			NSString *classKeyTextualCode = [delegateToCache instructionTextualCode];
			
			NSAssert([dictionaryOfInstructionsByOpcode valueForKey:classKeyOpcode] == nil, @"Opcode collision!");
			NSAssert([dictionaryOfInstructionsByTextualCode valueForKey:classKeyTextualCode] == nil, @"Textual code collision!");
			
			[dictionaryOfInstructionsByOpcode setValue:delegateToCache forKey:classKeyOpcode];
			[dictionaryOfInstructionsByTextualCode setValue:delegateToCache forKey:classKeyTextualCode];
			
		}
		
		
		self.cacheByOpcode = dictionaryOfInstructionsByOpcode;
		self.cacheByTextualCode = dictionaryOfInstructionsByTextualCode;
		
		
		
		
		
	}
	return self;
}


-(NSObject<VCInstructionDelegate>*) delegateForOpcode:(int)opcode {
	id delegateToReturn = nil;
	
	NSString *classKey = [NSString stringWithFormat:@"%i", opcode];
	
	delegateToReturn = [self.cacheByOpcode valueForKey:classKey];
	
	if (!delegateToReturn) {
		delegateToReturn = [[VCInstructionNopDelegate alloc] init];
	}
	
	return delegateToReturn;
}


-(NSObject<VCInstructionDelegate>*) delegateForTextualCode:(NSString*)textualCode {
	id delegateToReturn = nil;
	
	NSString *classKey = textualCode;
	
	delegateToReturn = [self.cacheByTextualCode valueForKey:classKey];
	
	if (!delegateToReturn) {
		delegateToReturn = [[VCInstructionNopDelegate alloc] init];
	}
	
	return delegateToReturn;	
}

@end
