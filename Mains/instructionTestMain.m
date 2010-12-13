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

#import "TestRunner.h"

int main(int argc, char *argv[])
{	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	NSMutableArray *arrayOfInstructionNamesToTest = 
	[[[NSMutableArray alloc] init] autorelease];
	
	
	// Data transfer
	[arrayOfInstructionNamesToTest addObject:@"LW"];
	[arrayOfInstructionNamesToTest addObject:@"LWI"];
	[arrayOfInstructionNamesToTest addObject:@"SW"];
	[arrayOfInstructionNamesToTest addObject:@"SWI"];
	
	// Logical
	[arrayOfInstructionNamesToTest addObject:@"AND"];
	[arrayOfInstructionNamesToTest addObject:@"ANDI"];
	[arrayOfInstructionNamesToTest addObject:@"OR"];
	[arrayOfInstructionNamesToTest addObject:@"ORI"];
	[arrayOfInstructionNamesToTest addObject:@"XOR"];
	[arrayOfInstructionNamesToTest addObject:@"NOT"];
	[arrayOfInstructionNamesToTest addObject:@"SLT"];
	[arrayOfInstructionNamesToTest addObject:@"SLTI"];
	
	// Branch
	[arrayOfInstructionNamesToTest addObject:@"BEQ"];
	[arrayOfInstructionNamesToTest addObject:@"BNE"];
	[arrayOfInstructionNamesToTest addObject:@"BGT"];
	[arrayOfInstructionNamesToTest addObject:@"BGE"];
	[arrayOfInstructionNamesToTest addObject:@"BLT"];
	[arrayOfInstructionNamesToTest addObject:@"BLE"];
	
	// Jump
	[arrayOfInstructionNamesToTest addObject:@"JMP"];
	[arrayOfInstructionNamesToTest addObject:@"JMPR"];
	
	// Misc
	[arrayOfInstructionNamesToTest addObject:@"IN"];
	[arrayOfInstructionNamesToTest addObject:@"OUT"];
	[arrayOfInstructionNamesToTest addObject:@"NOP"];
	[arrayOfInstructionNamesToTest addObject:@"HALT"];
	
	// Shift
	[arrayOfInstructionNamesToTest addObject:@"SLL"];
	[arrayOfInstructionNamesToTest addObject:@"SRL"];
	
	// Arithmetic
	[arrayOfInstructionNamesToTest addObject:@"ADD"];
	[arrayOfInstructionNamesToTest addObject:@"ADDI"];
	[arrayOfInstructionNamesToTest addObject:@"SUB"];
	[arrayOfInstructionNamesToTest addObject:@"SUBI"];
	[arrayOfInstructionNamesToTest addObject:@"MUL"];
	[arrayOfInstructionNamesToTest addObject:@"DIV"];
	
	
	// Our fibonacci calculator! Whoooo!!!
	[arrayOfInstructionNamesToTest addObject:@"FIB"];
	

	
	TestRunner *testRunner = [[[TestRunner alloc] init] autorelease];
	for (NSString *instruction in arrayOfInstructionNamesToTest) {
		BOOL result = [testRunner runTestForInstruction:instruction];
		if (result) {
			NSLog(@"%@ test result: YES", instruction);
		} else {
			NSLog(@"XXX: %@ test result: NO", instruction);
		}
	}
	
	// Now we should clean up after ourselves...
	NSError *error = NULL;
	[[NSFileManager defaultManager] 
	 removeItemAtPath:[TestRunner tempDirectoryPath] 
	 error:&error];
	
	if (error) {
		NSLog(@"%@", error);
		NSLog(@"You should remember to remove <%@> yourself.", 
					[TestRunner tempDirectoryPath]);
	}	
	
	
	[pool drain];
	return 0;	
}
