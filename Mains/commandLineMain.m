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

#import "DDArgumentManager.h"
#import "DDUtility.h"
#import "VCVirtualComputer.h"

int main(int argc, char *argv[])
{	
	@autoreleasepool {
	
		DDArgumentManager *argumentManager = 
		[[DDArgumentManager alloc] initWithArgCount:argc 
												argv:argv 
										  flagsToUse:@[@"-i", // Input file
													  @"-o", // Output file
													  @"-c"]];


		NSString *inputFile = [argumentManager associatedValueForFlag:@"-i"];
		NSString *outputFile = [argumentManager associatedValueForFlag:@"-o"];
		NSString *cycles = [argumentManager associatedValueForFlag:@"-c"];
		
		if (!inputFile) {
			[DDUtility print:@"You must specify an input file.\nUsage: virtualComputer -i input -o output -c cycles"];
			return 0;
		}
		
		if (!outputFile) {
			outputFile = @"vc.state";
		}
		
		if (!cycles) {
			cycles = @"-1";
		}
		
		
		VCVirtualComputer *virtualComputer = [[VCVirtualComputer alloc] init];

		virtualComputer.cyclesToRun = [cycles intValue];

		NSDictionary *stateToLoad = [NSDictionary dictionaryWithContentsOfFile:inputFile];
		[virtualComputer loadState:stateToLoad];

		
		[virtualComputer compute];
		
		
		NSDictionary *stateToReturn = [virtualComputer state];	
		[stateToReturn writeToFile:outputFile atomically:YES];
		
		
	}
	return 0;	
}
