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

@implementation TestRunner
+(NSString*) tempDirectoryPath {
	return [@"~/.virtual-computer-test-directory-delete-when-done" 
					stringByExpandingTildeInPath];
}

-(BOOL) runTestForInstruction:(NSString*)instruction {
	
	// Now for each one we compile the appropriate INST_test.s file with vcassem
	// to INST_state.initial and then run it with virtualComputer to
	// INST_state.final. We then compare that file with the INST_state.expected
	// file.
	
	// This is where the test files and the expected results are copied to
	// remember. If you want to change it look in the target for the copy
	// files build phase.
	NSString *testDirectory = [self.class tempDirectoryPath];
	
	// Make sure our test directory exists
	NSError *error = nil;
	[[NSFileManager defaultManager] createDirectoryAtPath:testDirectory 
							  withIntermediateDirectories:YES 
											   attributes:nil 
													error:&error];
	if (error) {
		NSLog(@"%@", error);
		return NO;
	}
	
	
	// Instructions.... ASSEMBLE!!
	NSString *instructionAssemblyFile = 
	[NSString stringWithFormat:
	 @"%@/%@_test.s", 
	 testDirectory, 
	 instruction];
	
	NSString *compiledInstructionFile = 
	[NSString stringWithFormat:
	 @"%@/%@_state.initial", 
	 testDirectory, 
	 instruction];
	
	NSArray *vcassemArgs = 
	@[@"-i", 
	 instructionAssemblyFile, 
	 @"-o", 
	 compiledInstructionFile];
	
	NSTask *vcassemTask = [[NSTask alloc] init];
	[vcassemTask setLaunchPath:
	 [NSString stringWithFormat:
		 @"%@/vcassem", 
		 testDirectory]];
	
	[vcassemTask setArguments:vcassemArgs];
	[vcassemTask launch];
	[vcassemTask waitUntilExit];
	
	
	
	// Now execute!
	NSString *executedInstructionFile = 
	[NSString stringWithFormat:@"%@/%@_state.final", testDirectory, instruction];
	
	NSArray *virtualComputerArgs = 
	@[@"-i", 
	 compiledInstructionFile, 
	 @"-o", 
	 executedInstructionFile];
	
	NSTask *virtualComputerTask = [[NSTask alloc] init];
	[virtualComputerTask setLaunchPath:
	 [NSString stringWithFormat:
		 @"%@/virtualComputer", 
		 testDirectory]];
	
	[virtualComputerTask setArguments:virtualComputerArgs];
	[virtualComputerTask launch];
	[virtualComputerTask waitUntilExit];
	
	
	
	// Now compare!!
	NSString *expectedResultsFile = 
	[NSString stringWithFormat:
	 @"%@/%@_state.expected", 
	 testDirectory, 
	 instruction];
	
	NSDictionary *expectedResultsDictionary = 
	[NSDictionary dictionaryWithContentsOfFile:expectedResultsFile];
	
	NSDictionary *actualResultsDictionary = 
	[NSDictionary dictionaryWithContentsOfFile:executedInstructionFile];

	if ([expectedResultsDictionary isEqualTo:actualResultsDictionary]) {
		return YES;
	} else {
		return NO;
	}
}

@end
