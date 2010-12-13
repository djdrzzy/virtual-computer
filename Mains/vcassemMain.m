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

#import "VCAssemblerHelper.h"

#import "DDArgumentManager.h"
#import "DDUtility.h"

int main(int argc, char *argv[]) {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	DDArgumentManager *argumentManager = 
	[[[DDArgumentManager alloc] initWithArgCount:argc 
											argv:argv 
									  flagsToUse:[NSArray arrayWithObjects:
												  @"-i", // Input file
												  @"-o", // Output file
												  nil]] autorelease];
	
	
	NSString *inputFile = [argumentManager associatedValueForFlag:@"-i"];
	NSString *outputFile = [argumentManager associatedValueForFlag:@"-o"];
	
	if (!inputFile) {
		[DDUtility print:@"You must specify an input file.\nUsage: vcassem -i input -o output"];
		return 0;
	}
	
	if (!outputFile) {
		outputFile = @"a.out";
	}
	
	NSMutableString *inputString = [[NSMutableString alloc] initWithContentsOfFile:inputFile 
																		  encoding:NSUTF8StringEncoding 
																			 error:NULL];
		
	VCAssemblerHelper *helper = [[VCAssemblerHelper alloc] init];;

	NSMutableArray *rowsToParse = 
	[[NSMutableArray alloc] initWithArray:[inputString componentsSeparatedByString:@"\n"]];
	
	// We now have prepped the input for parsing. So construct a computer
	
	NSMutableDictionary *assembledComputer = [[helper parseInput:rowsToParse] retain];
	
	// And write it out
	[assembledComputer writeToFile:outputFile atomically:YES];
	
	[rowsToParse release];
	[assembledComputer release];
	[inputString release];
	
	[helper release];
	
	[pool drain];
	return 0;	
}

