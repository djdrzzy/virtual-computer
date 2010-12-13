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

#import "VCInstructionBranchOnEqualDelegate.h"

#import "VCInstruction.h"
#import "VCMemory.h"
#import "VCRegisters.h"

@implementation VCInstructionBranchOnEqualDelegate


-(int8_t)instructionOperationCode {
	return 28;
}


-(NSString*)instructionTextualCode {
	return @"BEQ";
}


-(void)runWithInstruction:(VCInstruction*)instruction {
	
	VCRegisters *registers = instruction.registerTable;
	VCMemory *memory = instruction.memoryTable;
	
	int fieldZero = instruction.fieldZero;
	int fieldOne = instruction.fieldOne;
	
	// Remember we go and grab the next memory address as we take up two blocks for this instruction
	int fieldTwo = [memory valueOfMemoryAddress:(registers.programCounter + 1) % [memory lengthOfAddressSpace]];
	
	int valueZero = [registers valueOfRegister:fieldZero];
	int valueOne = [registers valueOfRegister:fieldOne];
	
	if (valueZero == valueOne) {
		// Branch to the place we need to
		registers.programCounter = fieldTwo;
	} else {
		// Advance the program counter to take us past our 2nd block of memory
		[registers advanceProgramCounter];
		[registers advanceProgramCounter];
	}	
}

@end
