//
//  VCInstructionBaseDelegate.m
//  Virtual Computer
//
//  Created by Daniel Drzimotta on 09-09-26.
//  Copyright 2009 Daniel Drzimotta. All rights reserved.
//

#import "VCInstructionBaseDelegate.h"


@implementation VCInstructionBaseDelegate

static VCInstructionBaseDelegate *_sharedInstance = nil;

+ (VCInstructionBaseDelegate*) sharedInstance
{
	if (_sharedInstance == nil) {
		@synchronized([VCInstructionBaseDelegate class])
		{
			if (!_sharedInstance) {
				[[self alloc] init];
			}
		}
	}
	
	return _sharedInstance;
}

+ (id) alloc
{
	NSAssert(_sharedInstance == nil, 
			 @"Attempted to allocate a second instance of a singleton.");
	if (_sharedInstance == nil) {
		_sharedInstance = [super alloc];		
	}
	
	return _sharedInstance;
}

@end
