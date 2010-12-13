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

#import "VCVirtualComputer.h"

#import "VCInstruction.h"
#import "VCInstructionDelegateCache.h"
#import "VCMemory.h"
#import "VCRegisters.h"


@implementation VCVirtualComputer


-(id) init {
	
	self = [super init];
	
	if(self != nil) {
		self.registerTable = [[[VCRegisters alloc] initWithAssociatedComputer:self] autorelease];
		self.memoryTable = [[[VCMemory alloc] initWithAssociatedComputer:self] autorelease];
		self.delegateCache = [[[VCInstructionDelegateCache alloc] init] autorelease];
	}
	   
	   return self; 
}

-(void) dealloc {
	self.registerTable = nil;
	self.memoryTable = nil;
	self.delegateCache = nil;
	
	[super dealloc];
}

-(void) loadState:(NSDictionary*)plist {
	// Construct the state for the computer
	[self.registerTable loadStateWithRegisterTable:[plist valueForKey:@"registers"]];
	[self.memoryTable loadStateWithMemoryTable:[plist valueForKey:@"memory"]];
}

-(NSDictionary*)state {
	
	NSArray *memoryArray = [self.memoryTable state];
	NSDictionary *registerDictionary = [self.registerTable state];
	
	NSMutableDictionary *plistToConstruct = [NSMutableDictionary dictionary];

	[plistToConstruct setValue:memoryArray forKey:@"memory"];
	[plistToConstruct setValue:registerDictionary forKey:@"registers"];
	
	return plistToConstruct;
}


-(void) compute {
	int32_t cyclesRan = 0;
	
	if (self.cyclesToRun < 0) {
		// loop until HALT
		while (!self.registerTable.haltedFlag && self.cyclesToRun) {
			[self clockTick];
		}
	} else {
		// We do some extra checking to make sure we don't hit our limit for cycles
		while (!self.registerTable.haltedFlag && cyclesRan < self.cyclesToRun) {
			[self clockTick];
			cyclesRan++;
		}
	}

}

-(void)clockTick {
	if(!self.registerTable.haltedFlag) {
		int currentInstructionAddress = 
			self.registerTable.programCounter;
		
		VCInstruction *currentInstruction = 
			[self.memoryTable instructionAtMemoryAddress:currentInstructionAddress];
		
		[currentInstruction run];
	}
}

-(u_int32_t) lengthOfAddressSpace {
	return [self.memoryTable lengthOfAddressSpace];;
}

@end
