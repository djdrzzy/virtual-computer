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

#import "VCMemory.h"

#import "VCInstruction.h"
#import "VCVirtualComputer.h"

@interface VCMemory ()
@property (nonatomic, readwrite, strong) NSMutableArray        *memoryTable;
@property (nonatomic, readwrite, weak) VCVirtualComputer   *associatedComputer;
@end

@implementation VCMemory

@synthesize memoryTable;
@synthesize associatedComputer;

-(void)loadStateWithMemoryTable:(NSMutableArray*)newMemoryTable {
	
	NSMutableArray *memoryTableToMake = [NSMutableArray arrayWithArray:newMemoryTable];
	
	for(u_int32_t i = 0; i < [memoryTableToMake count]; i++) {
		int currentMemoryAddressValue = [memoryTableToMake[i] intValue];
		VCInstruction *instructionToAdd = 
		[[VCInstruction alloc] initWithNumericalRepresentation:currentMemoryAddressValue
												 registerTable:self.associatedComputer.registerTable
												   memoryTable:self
												 delegateCache:self.associatedComputer.delegateCache];
		
		memoryTableToMake[i] = instructionToAdd;
	}
	
	self.memoryTable = memoryTableToMake;
}

-(id) initWithAssociatedComputer:(VCVirtualComputer*)newAssociatedComputer {
	self = [super init];
	
	if (self != nil) {	
		self.associatedComputer = newAssociatedComputer;
		[self loadStateWithMemoryTable:
			[[NSMutableArray alloc] initWithObjects:@0x00000000, nil]];
	}
	
	return self;	
}


-(id) init {
	return [self initWithAssociatedComputer:nil];
}

- (void) dealloc
{
	self.associatedComputer = nil;
}


-(void)setMemoryAddress:(u_int32_t)theAddress withValue:(int32_t)theNewValue {
	VCInstruction *instructionToAdd = 
	[[VCInstruction alloc] initWithNumericalRepresentation:theNewValue
											 registerTable:self.associatedComputer.registerTable
											   memoryTable:self
											 delegateCache:self.associatedComputer.delegateCache];
	
	(self.memoryTable)[(theAddress % self.memoryTable.count)] = instructionToAdd;	
}


-(int32_t)valueOfMemoryAddress:(u_int32_t)theAddress {
	return [(self.memoryTable)[theAddress % self.memoryTable.count] numericalRepresentation];
}

-(VCInstruction*)instructionAtMemoryAddress:(u_int32_t)theAddress {
	return (self.memoryTable)[theAddress % self.memoryTable.count];
}

-(u_int32_t) lengthOfAddressSpace {
	return (u_int32_t)self.memoryTable.count;
}

-(NSArray*) state {
	NSMutableArray *memoryArray = [NSMutableArray array];
	for(VCInstruction *instruction in self.memoryTable) {
		[memoryArray addObject:@([instruction numericalRepresentation])];
	}
	return memoryArray;
}

@end
