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

#import "VCInstruction.h"
#import "VCInstructionDelegate.h"
#import "VCInstructionDelegateCache.h"

@implementation VCInstruction

@synthesize numericalRepresentation;
@synthesize registerTable;
@synthesize memoryTable;
@synthesize delegateCache;


-(id)initWithNumericalRepresentation:(int32_t)newNumericalRepresentation
					   registerTable:(VCRegisters*)newRegisterTable
						 memoryTable:(VCMemory*)newMemoryTable
					   delegateCache:(VCInstructionDelegateCache*)newDelegateCache {
	
	self = [super init];
	
	if (self != nil) {
		self.numericalRepresentation = newNumericalRepresentation;
		self.registerTable = newRegisterTable;
		self.memoryTable = newMemoryTable;
		self.delegateCache = newDelegateCache;
	}
	
	return self;
}

-(id)init {
	return [self initWithNumericalRepresentation:0x00000000
								   registerTable:nil
									 memoryTable:nil
								   delegateCache:nil];
}

-(void)run {
	
	// created on the fly. We don't need it as an instance variable... hopefully anyways.
	id delegate = [self.delegateCache delegateForOpcode:[self opCode]];
	
	if([delegate respondsToSelector:@selector(runWithInstruction:)]) {
		[delegate runWithInstruction:self];
	}
}

-(int8_t)opCode {
	return (int8_t)((0xFF000000 & numericalRepresentation) >> 24); 
}

-(int8_t)fieldZero {
	return (int8_t)((0x00FF0000 & numericalRepresentation) >> 16);
}

-(int8_t)fieldOne {
	return (int8_t)((0x0000FF00 & numericalRepresentation) >> 8);
}

-(int8_t)fieldTwo {
	return (int8_t)((0x000000FF & numericalRepresentation));
}

-(void)setOpCode:(int8_t)newOpCode {
	[self clearOpCode];
	numericalRepresentation = numericalRepresentation | ((int32_t)newOpCode << 24);
}

-(void)setFieldZero:(int8_t)newFieldZero {
	[self clearFieldZero];
	numericalRepresentation = numericalRepresentation | ((int32_t)newFieldZero << 16);
}

-(void)setFieldOne:(int8_t)newFieldOne {
	[self clearFieldOne];
	numericalRepresentation = numericalRepresentation | ((int32_t)newFieldOne << 8);
}

-(void)setFieldTwo:(int8_t)newFieldTwo {
	[self clearFieldTwo];
	numericalRepresentation = numericalRepresentation | (int32_t)newFieldTwo;
}

-(void)clearOpCode {
	numericalRepresentation = numericalRepresentation & 0x00FFFFFF;
}

-(void)clearFieldZero {
	numericalRepresentation = numericalRepresentation & 0xFF00FFFF;
}

-(void)clearFieldOne {
	numericalRepresentation = numericalRepresentation & 0xFFFF00FF;
}

-(void)clearFieldTwo {
	numericalRepresentation = numericalRepresentation & 0xFFFFFF00;
}

@end
