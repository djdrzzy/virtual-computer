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

#import "VCInstructionShiftLeftLogicalDelegate.h"

#import "VCInstruction.h"
#import "VCRegisters.h"

@implementation VCInstructionShiftLeftLogicalDelegate


-(int8_t)instructionOperationCode {
	return 25;
}


-(NSString*)instructionTextualCode {
	return @"SLL";
}


-(void)runWithInstruction:(VCInstruction*)instruction {
	
	VCRegisters *registers = instruction.registerTable;
	
	int fieldZero = instruction.fieldZero;
	int fieldOne = instruction.fieldOne;
	int fieldTwo = instruction.fieldTwo;
	
	int valueZero = [registers valueOfRegister:fieldZero];
	int valueOne = [registers valueOfRegister:fieldOne];
	
	int finalValue = (uint)valueZero << valueOne;
	
	[registers setValueOfRegister:fieldTwo withValue:finalValue];
	
	[registers advanceProgramCounter];
}

@end
