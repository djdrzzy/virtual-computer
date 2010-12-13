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

#import "VCInstruction.h"
#import "VCInstructionDelegateCache.h"

@interface VCAssemblerHelper ()
@property (nonatomic, retain) NSMutableDictionary *actualLabelCache;

@property (nonatomic, retain) NSNumber *programCounter;
@property (nonatomic, retain) NSNumber *haltFlag;
@property (nonatomic, copy) NSString *input;
@property (nonatomic, copy) NSString *output;
@property (nonatomic, retain) NSMutableArray *individualRegisters;
@property (nonatomic, retain) NSMutableArray *memory;

@property (nonatomic, retain) VCInstructionDelegateCache *delegateCache;

@property (nonatomic, retain) NSArray *currentSeperatedInstruction;
@property (nonatomic, copy) NSString *currentInstructionToParse;
@property (nonatomic, copy) NSString *command;

@property (nonatomic, retain) NSDictionary *commandMapper;

-(NSDictionary*) constructCommandMapper;
-(NSMutableArray*)removeLinesWithHash:(NSMutableArray*)arrayToClean;
-(NSMutableArray*)removeEmptyLines:(NSMutableArray*)arrayToClean;
@end

@implementation VCAssemblerHelper

-(id) init {
	self = [super init];
	
	if(self != nil) {
		self.actualLabelCache = [[[NSMutableDictionary alloc] init] autorelease];
		self.commandMapper = [self constructCommandMapper];
	}
	
	return self;
}


-(void) dealloc {
	self.actualLabelCache = nil;
	self.commandMapper = nil;
	
	self.delegateCache = nil;
	
	self.programCounter = nil;
	self.haltFlag = nil;
	self.input = nil;
	self.output = nil;
	
	self.individualRegisters = nil;
	self.memory = nil;
	
	self.currentSeperatedInstruction = nil;
	self.currentInstructionToParse = nil;
	self.command = nil;
	
	[super dealloc];
}

-(NSMutableDictionary*)parseInput:(NSMutableArray*)arrayToParse {
	NSMutableDictionary *constructedComputer = 
	[[[NSMutableDictionary alloc] init] autorelease];
	
	// First we want to remove all lines that start with a #
	NSMutableArray *rowsWithNoHashes = 
	[self removeLinesWithHash:arrayToParse];
	
	// Now remove all lines with nothing on them
	NSMutableArray *rowsWithNoEmpties = 
	[self removeEmptyLines:rowsWithNoHashes];
	
	// Our delegate cache to get our delegates from our instruction textual codes
	self.delegateCache = [[[VCInstructionDelegateCache alloc] init] autorelease];
	
	// Stuff to add in our computer later, default values
	self.programCounter = [NSNumber numberWithInt:0];
	self.haltFlag = [NSNumber numberWithBool:NO];
	self.input = @"";
	self.output = @"";
	
	self.individualRegisters = [[[NSMutableArray alloc] init] autorelease];
	self.memory = [[[NSMutableArray alloc] init] autorelease];
	
	for(NSString *instructionToParse in rowsWithNoEmpties) {
		
		// Move this outside to class scope
		self.currentInstructionToParse = instructionToParse;
		
		// First divide our string by whitespace and then get the first field.
		self.currentSeperatedInstruction = 
		[instructionToParse componentsSeparatedByString:@" "];
		
		self.command = [currentSeperatedInstruction objectAtIndex:0];
		
		NSString *methodToUse = nil;
		
		if ([command hasPrefix:@"*"]) {
			methodToUse = [self.commandMapper valueForKey:@"*"];
		} else {
			methodToUse = [self.commandMapper valueForKey:command];
		}
		
		[self performSelector:NSSelectorFromString(methodToUse)];
	}
	
	
	// Now iterate over our memory replacing parts that if they're strings and 
	// start with * with their actual label cache values
	
	for(uint i = 0; i < memory.count; i++) {
		id memoryValue = [memory objectAtIndex:i];
		
		if ([memoryValue isKindOfClass:[NSString class]] 
				&& [memoryValue hasPrefix:@"*"]) {
			
			[memory replaceObjectAtIndex:i 
												withObject:[actualLabelCache valueForKey:memoryValue]];
		}
	}
	
	NSMutableDictionary *registers = [[[NSMutableDictionary alloc] init] autorelease];
	[registers setValue:programCounter forKey:@"programCounter"];
	[registers setValue:haltFlag forKey:@"haltFlag"];
	[registers setValue:input forKey:@"input"];
	[registers setValue:output forKey:@"output"];
	[registers setValue:individualRegisters forKey:@"genericRegisters"];
	
	[constructedComputer setValue:registers forKey:@"registers"];
	[constructedComputer setValue:memory forKey:@"memory"];
	
	return constructedComputer;
}

-(NSMutableArray*)removeLinesWithHash:(NSMutableArray*)arrayToClean {
	
	NSMutableArray *cleanedArray = [[[NSMutableArray alloc] init] autorelease];
	
	for(uint i = 0; i < arrayToClean.count; i++) {
		if (![[arrayToClean objectAtIndex:i] hasPrefix:@"#"]) {
			[cleanedArray addObject:[arrayToClean objectAtIndex:i]];
		}
	}
	
	return cleanedArray;
}

-(NSMutableArray*)removeEmptyLines:(NSMutableArray*)arrayToClean {
	
	NSMutableArray *cleanedArray = [[[NSMutableArray alloc] init] autorelease];
	
	for(uint i = 0; i < arrayToClean.count; i++) {
		if (![[[arrayToClean objectAtIndex:i] stringByTrimmingCharactersInSet:
					 [NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
			[cleanedArray addObject:[arrayToClean objectAtIndex:i]];
		}
	}
	
	return cleanedArray;	
}

-(NSDictionary*) constructCommandMapper {
	return [NSDictionary dictionaryWithObjectsAndKeys:
													 @"processCommandPC", @"PC",
													 @"processCommandHF",@"HF",
													 @"processCommandINPUT", @"INPUT",
													 @"processCommandOUTPUT",@"OUTPUT",
													 @"processCommandREG", @"REG",
													 @"processCommandMEM", @"MEM",
													 @"processCommandPADMEM", @"PADMEM",
													 
													 @"processCommandClass0", @"NOP",
													 @"processCommandClass0", @"HALT",
													 
													 @"processCommandClass1", @"ADD",
													 @"processCommandClass1", @"SUB",
													 @"processCommandClass1", @"MUL",
													 @"processCommandClass1", @"DIV",
													 @"processCommandClass1", @"AND",
													 @"processCommandClass1", @"OR",
													 @"processCommandClass1", @"XOR",
													 @"processCommandClass1", @"SLT",
													 @"processCommandClass1", @"SLL",
													 @"processCommandClass1", @"SRL",
													 
													 @"processCommandClass2", @"ADDI",
													 @"processCommandClass2", @"SUBI",
													 @"processCommandClass2", @"ANDI",
													 @"processCommandClass2", @"ORI",
													 @"processCommandClass2", @"SLTI",
													 
													 @"processCommandClass3", @"BEQ",
													 @"processCommandClass3", @"BNE",
													 @"processCommandClass3", @"BGT",
													 @"processCommandClass3", @"BGE",
													 @"processCommandClass3", @"BLT",
													 @"processCommandClass3", @"BLE",
													 
													 @"processCommandClass4", @"IN",
													 @"processCommandClass4", @"OUT",
													 @"processCommandClass4", @"JMPR",
													 
													 @"processCommandClass5", @"SW",
													 @"processCommandClass5", @"LW",
													 
													 @"processCommandClass6", @"JMP",
													 
													 @"processCommandClass7", @"NOT",
													 
													 @"processCommandClass8", @"LWI",
													 @"processCommandClass8", @"SWI",
													 
													 @"processCommandForLabelProcessing", @"*",
													 nil];
}

- (void) processCommandPC {
	// Here we just automatically overwrite whatever programCounter was
	programCounter = 
	[NSNumber numberWithInteger:[[currentSeperatedInstruction objectAtIndex:1] 
															 integerValue]];
	
}

- (void) processCommandHF {
	// Same with the haltFlag
	haltFlag = 
	[NSNumber numberWithBool:[[currentSeperatedInstruction objectAtIndex:1] 
														boolValue]];
	
}

- (void) processCommandINPUT {
	// Here we need to get everything past "INPUT "
	input = [self.currentInstructionToParse substringFromIndex:6];
	
}

- (void) processCommandOUTPUT {
	// And same past "OUTPUT "
	output = [self.currentInstructionToParse substringFromIndex:7];
	
}

- (void) processCommandREG {
	// We add a register with the supplied initial value
	NSNumber *newRegister = 
	[NSNumber numberWithInteger:[[currentSeperatedInstruction objectAtIndex:1] 
															 integerValue]];
	
	[individualRegisters addObject:newRegister];
	
}

- (void) processCommandMEM {
	// We add a memory location with the supplied value
	NSNumber *newMem = 
	[NSNumber numberWithInteger:[[currentSeperatedInstruction objectAtIndex:1] 
															 integerValue]];
	
	[memory addObject:newMem];
	
}

- (void) processCommandPADMEM {
	// We pad the memory with nops for however many specified
	
	NSInteger numberOfNops = [[currentSeperatedInstruction objectAtIndex:1] 
														integerValue];
	
	for(NSInteger i = 0; i < numberOfNops; i++) {
		NSNumber *nop = [NSNumber numberWithInteger:0];
		[memory addObject:nop];
	}
	
}

- (void) processCommandClass0 {
	// Class 0 of our instructions. Their format is just their command
	// EX: HALT
	// There are no operands
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	[memory addObject:numberToUse];
	
	[instructionToUse release];
	
}

- (void) processCommandClass1 {
	// Class 1 of our instructions. These only deal with registers. Field 1 of the
	// instruction is the first source. Field 2 of the instruction is the second 
	// source. Field 3 is the destination. We only deal with one memory location 
	// with this class. They're nice.
	
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero = 
	[[currentSeperatedInstruction objectAtIndex:1] intValue];
	
	instructionToUse.fieldOne = 
	[[currentSeperatedInstruction objectAtIndex:2] intValue];
	
	instructionToUse.fieldTwo = 
	[[currentSeperatedInstruction objectAtIndex:3] intValue];
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	[memory addObject:numberToUse];
	
	[instructionToUse release];
	
}

- (void) processCommandClass2 {
	// Class 2 of our instructions. These are mainly the same as class 1 except 
	// they use an immediate value and store it right after the constructed 
	// instruction.
	
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero = 
	[[currentSeperatedInstruction objectAtIndex:1] integerValue];
	
	instructionToUse.fieldTwo = 
	[[currentSeperatedInstruction objectAtIndex:3] integerValue];
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	NSNumber *immediateStorage = 
	[NSNumber numberWithInteger:[[currentSeperatedInstruction objectAtIndex:2] 
															 integerValue]];
	
	[memory addObject:numberToUse];
	[memory addObject:immediateStorage];
	
	[instructionToUse release];
	
}

- (void) processCommandClass3 {
	// Class 3 of our instructions. Mainly branching. I can't think of what it 
	// would be otherwise... maybe we will get lucky?
	
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero = 
	[[currentSeperatedInstruction objectAtIndex:1] integerValue];
	
	instructionToUse.fieldOne = 
	[[currentSeperatedInstruction objectAtIndex:2] integerValue];
	
	id immediateStorage;
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	if ([[currentSeperatedInstruction objectAtIndex:3] hasPrefix:@"*"]) {
		immediateStorage = [currentSeperatedInstruction objectAtIndex:3]; 
	} else {
		immediateStorage = 
		[NSNumber numberWithInteger:[[currentSeperatedInstruction objectAtIndex:3] 
																 integerValue]];
	}
	
	
	[memory addObject:numberToUse];
	[memory addObject:immediateStorage];
	
	[instructionToUse release];
	
}

- (void) processCommandClass4 {
	// Class 4 of our instructions.
	
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero = 
	[[currentSeperatedInstruction objectAtIndex:1] integerValue];
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	[memory addObject:numberToUse];
	
	[instructionToUse release];
	
}

- (void) processCommandClass5 {
	// Class 5
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero = 
	[[currentSeperatedInstruction objectAtIndex:1] integerValue];
	
	instructionToUse.fieldOne = 
	[[currentSeperatedInstruction objectAtIndex:2] integerValue];
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	[memory addObject:numberToUse];
	
	[instructionToUse release];
	
}

- (void) processCommandClass6 {
	// Class 6 of our instructions...
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	id immediateStorage;
	
	if ([[currentSeperatedInstruction objectAtIndex:1] hasPrefix:@"*"]) {
		immediateStorage = [currentSeperatedInstruction objectAtIndex:1];
	} else {
		immediateStorage = 
		[NSNumber numberWithInteger:[[currentSeperatedInstruction objectAtIndex:1] 
																 integerValue]];
	}
	
	
	[memory addObject:numberToUse];
	[memory addObject:immediateStorage];
	
	[instructionToUse release];
	
}

- (void) processCommandClass7 {
	// Class 7 of our instructions...
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero = 
	[[currentSeperatedInstruction objectAtIndex:1] integerValue];
	
	instructionToUse.fieldOne = 
	[[currentSeperatedInstruction objectAtIndex:2] integerValue];
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	[memory addObject:numberToUse];
	
	[instructionToUse release];
	
}

- (void) processCommandClass8 {
	// Class 8
	id<VCInstructionDelegate> delegateToUse = 
	[delegateCache delegateForTextualCode:command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	instructionToUse.fieldZero = 
	[[currentSeperatedInstruction objectAtIndex:2] integerValue];
	
	NSNumber *numberToUse = 
	[NSNumber numberWithInteger:instructionToUse.numericalRepresentation];
	
	NSNumber *immediateStorage = 
	[NSNumber numberWithInteger:[[currentSeperatedInstruction objectAtIndex:1] 
															 integerValue]];
	
	[memory addObject:numberToUse];
	[memory addObject:immediateStorage];
	
	[instructionToUse release];
	
}

- (void) processCommandForLabelProcessing {
	// Label processing
	// We put it into our actual labels cache
	
	NSAssert(![actualLabelCache valueForKey:command], @"Label already exists!");
	
	NSNumber *labelAddress = [NSNumber numberWithInteger:memory.count];
	
	[actualLabelCache setValue:labelAddress forKey:command];
	
}

@end
