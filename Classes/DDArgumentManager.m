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


@implementation DDArgumentManager

-(id) initWithArgCount:(int)argc 
				  argv:(char*[])argv
			flagsToUse:(NSArray*)flags {

	self = [super init];
	if (self != nil) {
		flagMapping = [[NSMutableDictionary alloc] init];
		
		NSMutableArray *argumentArray = [NSMutableArray array];
		
		for(int i = 1; i < argc; i++) {
			[argumentArray addObject:[NSString stringWithUTF8String:argv[i]]];
		}
		
		NSSet *setOfFlags = [NSSet setWithArray:flags];
		
		for(NSUInteger i = 0; i < argumentArray.count; i++) {
			if ([setOfFlags containsObject:[argumentArray objectAtIndex:i]]) {
				if (i + 1 < argumentArray.count) {
					[flagMapping setValue:[argumentArray objectAtIndex:i+1] 
								   forKey:[argumentArray objectAtIndex:i]];
				}
			}
		}
	}
		
	return self;
}

- (void) dealloc
{
	[flagMapping release];
	[super dealloc];
}

-(NSString*) associatedValueForFlag:(NSString*)flag {
	return [flagMapping valueForKey:flag];
}

			
@end
