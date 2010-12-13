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

#import "VCRegisters.h"

#import "VCVirtualComputer.h"

static NSString *const REGISTER_STATE_KEY = @"genericRegisters";
static NSString *const INPUT_STATE_KEY = @"input";
static NSString *const OUTPUT_STATE_KEY = @"output";
static NSString *const PROGRAM_COUNTER_STATE_KEY = @"programCounter";
static NSString *const HALT_FLAG_STATE_KEY = @"haltFlag";

@interface VCRegisters ()
@property (nonatomic, retain) NSMutableArray      *registers;
@property (nonatomic, retain) NSMutableString     *inputRegister;
@property (nonatomic, retain) NSMutableString     *outputRegister;
@property (nonatomic, assign) VCVirtualComputer   *associatedComputer;
@end

@implementation VCRegisters
@synthesize registers;
@synthesize inputRegister;
@synthesize outputRegister;
@synthesize programCounter;
@synthesize haltedFlag;
@synthesize associatedComputer;


- (id) initWithAssociatedComputer:(VCVirtualComputer*)newAssociatedComputer {
	
	self = [super init];
	
	if (self != nil) {	
		self.associatedComputer = newAssociatedComputer;
		
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		
		[dictionary setValue:[[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0x00000000], nil] autorelease] forKey:REGISTER_STATE_KEY];
		[dictionary setValue:[[[NSMutableString alloc] initWithString:@""] autorelease] forKey:INPUT_STATE_KEY];
		[dictionary setValue:[[[NSMutableString alloc] initWithString:@""] autorelease] forKey:OUTPUT_STATE_KEY];
		[dictionary setValue:[NSNumber numberWithUnsignedInteger:0] forKey:PROGRAM_COUNTER_STATE_KEY];
		[dictionary setValue:[NSNumber numberWithBool:NO] forKey:HALT_FLAG_STATE_KEY];
		
		[self loadStateWithRegisterTable:dictionary];
		[dictionary release];
		
	}
	return self;
}


-(id) init {
	return [self initWithAssociatedComputer:nil];
}

-(void) dealloc {

	self.registers = nil;
	self.inputRegister = nil;
	self.outputRegister = nil;
	self.associatedComputer = nil;
	[super dealloc];
}


-(void)reset {
	for(u_int32_t i = 0; i < [registers count]; i++) {
		[registers replaceObjectAtIndex:(NSUInteger)i
							 withObject:[NSNumber numberWithInt:0]];
	}
}

-(void) advanceProgramCounter {
	programCounter++;
	
	if(programCounter >= [self.associatedComputer lengthOfAddressSpace])
		programCounter = 0;
}

-(void)setValueOfRegister:(NSUInteger)theRegister withValue:(int)theNewValue {
	[registers replaceObjectAtIndex:(NSUInteger)(theRegister % [registers count])
						 withObject:[NSNumber numberWithInt:theNewValue]];
}

-(int)valueOfRegister:(NSUInteger)theRegister {
	int valueToReturn = 
		[[registers objectAtIndex:((NSUInteger)theRegister % [registers count])] intValue];
	
	return valueToReturn;
}

-(int) valueOfInputRegister {
	if(inputRegister.length > 0) {
		int valueToReturn = (int)[inputRegister characterAtIndex:0];
		[inputRegister deleteCharactersInRange:NSMakeRange(0, 1)];
		return valueToReturn;
	} else return 0;
}

-(void) setValueOfOutputRegister:(int)valueToPush {
	NSString *valueToInsert = [[NSString alloc] initWithFormat:@"%c", (char)valueToPush];
	[outputRegister insertString:valueToInsert atIndex:0];
	[valueToInsert release];
}

-(NSDictionary*) state {
	NSMutableDictionary *dictionaryToReturn = [[[NSMutableDictionary alloc] init] autorelease];
	[dictionaryToReturn setValue:self.registers forKey:REGISTER_STATE_KEY];
	[dictionaryToReturn setValue:self.inputRegister forKey:INPUT_STATE_KEY];
	[dictionaryToReturn setValue:outputRegister forKey:OUTPUT_STATE_KEY];
	[dictionaryToReturn setValue:[NSNumber numberWithInt:self.programCounter] forKey:PROGRAM_COUNTER_STATE_KEY];
	[dictionaryToReturn setValue:[NSNumber numberWithBool:self.haltedFlag] forKey:HALT_FLAG_STATE_KEY];
	return dictionaryToReturn;
}

-(void)loadStateWithRegisterTable:(NSDictionary*)state {
	self.registers = [[[NSMutableArray alloc] initWithArray:[state valueForKey:REGISTER_STATE_KEY]] autorelease];
	self.inputRegister = [[[NSMutableString alloc] initWithString:[state valueForKey:INPUT_STATE_KEY]] autorelease];
	self.outputRegister = [[[NSMutableString alloc] initWithString:[state valueForKey:OUTPUT_STATE_KEY]] autorelease];
	self.programCounter = [[state valueForKey:PROGRAM_COUNTER_STATE_KEY] unsignedIntValue];
	self.haltedFlag = [[state valueForKey:HALT_FLAG_STATE_KEY] boolValue];
}


@end