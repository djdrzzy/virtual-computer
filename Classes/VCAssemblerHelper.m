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
@property (nonatomic, strong) NSMutableDictionary *actualLabelCache;

@property (nonatomic, strong) NSNumber *programCounter;
@property (nonatomic, strong) NSNumber *haltFlag;
@property (nonatomic, copy) NSString *input;
@property (nonatomic, copy) NSString *output;
@property (nonatomic, strong) NSMutableArray *individualRegisters;
@property (nonatomic, strong) NSMutableArray *memory;

@property (nonatomic, strong) VCInstructionDelegateCache *delegateCache;

@property (nonatomic, strong) NSArray *currentSeperatedInstruction;
@property (nonatomic, copy) NSString *currentInstructionToParse;
@property (nonatomic, copy) NSString *command;

@property (nonatomic, strong) NSDictionary *commandMapper;

-(NSDictionary*) constructCommandMapper;
-(NSMutableArray*)removeLinesWithHash:(NSMutableArray*)arrayToClean;
-(NSMutableArray*)removeEmptyLines:(NSMutableArray*)arrayToClean;
@end

@implementation VCAssemblerHelper

-(id) init {
	self = [super init];
	
	if(self != nil) {
		self.actualLabelCache = [[NSMutableDictionary alloc] init];
		self.commandMapper = [self constructCommandMapper];
	}
	
	return self;
}



-(NSMutableDictionary*)parseInput:(NSMutableArray*)arrayToParse {
	NSMutableDictionary *constructedComputer =
	[[NSMutableDictionary alloc] init];
	
	// First we want to remove all lines that start with a #
	NSMutableArray *rowsWithNoHashes =
	[self removeLinesWithHash:arrayToParse];
	
	// Now remove all lines with nothing on them
	NSMutableArray *rowsWithNoEmpties =
	[self removeEmptyLines:rowsWithNoHashes];
	
	// Our delegate cache to get our delegates from our instruction textual codes
	self.delegateCache = [[VCInstructionDelegateCache alloc] init];
	
	// Stuff to add in our computer later, default values
	self.programCounter = @0;
	self.haltFlag = @NO;
	self.input = @"";
	self.output = @"";
	
	self.individualRegisters = [[NSMutableArray alloc] init];
	self.memory = [[NSMutableArray alloc] init];
	
	for(NSString *instructionToParse in rowsWithNoEmpties) {
		
		// Move this outside to class scope
		self.currentInstructionToParse = instructionToParse;
		
		// First divide our string by whitespace and then get the first field.
		self.currentSeperatedInstruction =
		[instructionToParse componentsSeparatedByString:@" "];
		
		self.command = (self.currentSeperatedInstruction)[0];
		
		NSString *methodToUse = nil;
		
		if ([self.command hasPrefix:@"*"]) {
			methodToUse = [self.commandMapper valueForKey:@"*"];
		} else {
			methodToUse = [self.commandMapper valueForKey:self.command];
		}
		
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
		[self performSelector:NSSelectorFromString(methodToUse)];
#       pragma clang diagnostic pop
	}
	
	
	// Now iterate over our memory replacing parts that if they're strings and
	// start with * with their actual label cache values
	
	for(uint i = 0; i < self.memory.count; i++) {
		id memoryValue = (self.memory)[i];
		
		if ([memoryValue isKindOfClass:[NSString class]]
            && [memoryValue hasPrefix:@"*"]) {
			
			(self.memory)[i] = [_actualLabelCache valueForKey:memoryValue];
		}
	}
	
	NSMutableDictionary *registers = [[NSMutableDictionary alloc] init];
	[registers setValue:self.programCounter forKey:@"programCounter"];
	[registers setValue:self.haltFlag forKey:@"haltFlag"];
	[registers setValue:self.input forKey:@"input"];
	[registers setValue:self.output forKey:@"output"];
	[registers setValue:self.individualRegisters forKey:@"genericRegisters"];
	
	[constructedComputer setValue:registers forKey:@"registers"];
	[constructedComputer setValue:self.memory forKey:@"memory"];
	
	return constructedComputer;
}

-(NSMutableArray*)removeLinesWithHash:(NSMutableArray*)arrayToClean {
	
	NSMutableArray *cleanedArray = [[NSMutableArray alloc] init];
	
	for(uint i = 0; i < arrayToClean.count; i++) {
		if (![arrayToClean[i] hasPrefix:@"#"]) {
			[cleanedArray addObject:arrayToClean[i]];
		}
	}
	
	return cleanedArray;
}

-(NSMutableArray*)removeEmptyLines:(NSMutableArray*)arrayToClean {
	
	NSMutableArray *cleanedArray = [[NSMutableArray alloc] init];
	
	for(uint i = 0; i < arrayToClean.count; i++) {
		if (![[arrayToClean[i] stringByTrimmingCharactersInSet:
               [NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
			[cleanedArray addObject:arrayToClean[i]];
		}
	}
	
	return cleanedArray;
}

-(NSDictionary*) constructCommandMapper {
	return @{@"PC": @"processCommandPC",
            @"HF": @"processCommandHF",
            @"INPUT": @"processCommandINPUT",
            @"OUTPUT": @"processCommandOUTPUT",
            @"REG": @"processCommandREG",
            @"MEM": @"processCommandMEM",
            @"PADMEM": @"processCommandPADMEM",
            
            @"NOP": @"processCommandClass0",
            @"HALT": @"processCommandClass0",
            
            @"ADD": @"processCommandClass1",
            @"SUB": @"processCommandClass1",
            @"MUL": @"processCommandClass1",
            @"DIV": @"processCommandClass1",
            @"AND": @"processCommandClass1",
            @"OR": @"processCommandClass1",
            @"XOR": @"processCommandClass1",
            @"SLT": @"processCommandClass1",
            @"SLL": @"processCommandClass1",
            @"SRL": @"processCommandClass1",
            
            @"ADDI": @"processCommandClass2",
            @"SUBI": @"processCommandClass2",
            @"ANDI": @"processCommandClass2",
            @"ORI": @"processCommandClass2",
            @"SLTI": @"processCommandClass2",
            
            @"BEQ": @"processCommandClass3",
            @"BNE": @"processCommandClass3",
            @"BGT": @"processCommandClass3",
            @"BGE": @"processCommandClass3",
            @"BLT": @"processCommandClass3",
            @"BLE": @"processCommandClass3",
            
            @"IN": @"processCommandClass4",
            @"OUT": @"processCommandClass4",
            @"JMPR": @"processCommandClass4",
            
            @"SW": @"processCommandClass5",
            @"LW": @"processCommandClass5",
            
            @"JMP": @"processCommandClass6",
            
            @"NOT": @"processCommandClass7",
            
            @"LWI": @"processCommandClass8",
            @"SWI": @"processCommandClass8",
            
            @"*": @"processCommandForLabelProcessing"};
}

- (void) processCommandPC {
	// Here we just automatically overwrite whatever programCounter was
	self.programCounter =
	@([_currentSeperatedInstruction[1]
                                 integerValue]);
	
}

- (void) processCommandHF {
	// Same with the haltFlag
	self.haltFlag=
	@([_currentSeperatedInstruction[1]
                              boolValue]);
	
}

- (void) processCommandINPUT {
	// Here we need to get everything past "INPUT "
	_input= [self.currentInstructionToParse substringFromIndex:6];
	
}

- (void) processCommandOUTPUT {
	// And same past "OUTPUT "
	self.output = [self.currentInstructionToParse substringFromIndex:7];
	
}

- (void) processCommandREG {
	// We add a register with the supplied initial value
	NSNumber *newRegister =
	@([(self.currentSeperatedInstruction)[1]
                                 integerValue]);
	
	[self.individualRegisters addObject:newRegister];
	
}

- (void) processCommandMEM {
	// We add a memory location with the supplied value
	NSNumber *newMem =
	@([(self.currentSeperatedInstruction)[1]
                                 integerValue]);
	
	[self.memory addObject:newMem];
	
}

- (void) processCommandPADMEM {
	// We pad the memory with nops for however many specified
	
	NSInteger numberOfNops = [(self.currentSeperatedInstruction)[1]
                              integerValue];
	
	for(NSInteger i = 0; i < numberOfNops; i++) {
		NSNumber *nop = @0;
		[self.memory addObject:nop];
	}
	
}

- (void) processCommandClass0 {
	// Class 0 of our instructions. Their format is just their command
	// EX: HALT
	// There are no operands
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	[self.memory addObject:numberToUse];
	
	
}

- (void) processCommandClass1 {
	// Class 1 of our instructions. These only deal with registers. Field 1 of the
	// instruction is the first source. Field 2 of the instruction is the second
	// source. Field 3 is the destination. We only deal with one memory location
	// with this class. They're nice.
	
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero =
	[(self.currentSeperatedInstruction)[1] intValue];
	
	instructionToUse.fieldOne =
	[(self.currentSeperatedInstruction)[2] intValue];
	
	instructionToUse.fieldTwo =
	[(self.currentSeperatedInstruction)[3] intValue];
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	[self.memory addObject:numberToUse];
	
	
}

- (void) processCommandClass2 {
	// Class 2 of our instructions. These are mainly the same as class 1 except
	// they use an immediate value and store it right after the constructed
	// instruction.
	
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero =
	[(self.currentSeperatedInstruction)[1] integerValue];
	
	instructionToUse.fieldTwo =
	[(self.currentSeperatedInstruction)[3] integerValue];
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	NSNumber *immediateStorage =
	@([(self.currentSeperatedInstruction)[2]
                                 integerValue]);
	
	[self.memory addObject:numberToUse];
	[self.memory addObject:immediateStorage];
	
	
}

- (void) processCommandClass3 {
	// Class 3 of our instructions. Mainly branching. I can't think of what it
	// would be otherwise... maybe we will get lucky?
	
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero =
	[(self.currentSeperatedInstruction)[1] integerValue];
	
	instructionToUse.fieldOne =
	[(self.currentSeperatedInstruction)[2] integerValue];
	
	id immediateStorage;
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	if ([(self.currentSeperatedInstruction)[3] hasPrefix:@"*"]) {
		immediateStorage = (self.currentSeperatedInstruction)[3];
	} else {
		immediateStorage =
		@([(self.currentSeperatedInstruction)[3]
                                     integerValue]);
	}
	
	
	[self.memory addObject:numberToUse];
	[self.memory addObject:immediateStorage];
	
	
}

- (void) processCommandClass4 {
	// Class 4 of our instructions.
	
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero =
	[(self.currentSeperatedInstruction)[1] integerValue];
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	[self.memory addObject:numberToUse];
	
	
}

- (void) processCommandClass5 {
	// Class 5
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero =
	[(self.currentSeperatedInstruction)[1] integerValue];
	
	instructionToUse.fieldOne =
	[(self.currentSeperatedInstruction)[2] integerValue];
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	[self.memory addObject:numberToUse];
	
	
}

- (void) processCommandClass6 {
	// Class 6 of our instructions...
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	id immediateStorage;
	
	if ([(self.currentSeperatedInstruction)[1] hasPrefix:@"*"]) {
		immediateStorage = (self.currentSeperatedInstruction)[1];
	} else {
		immediateStorage =
		@([(self.currentSeperatedInstruction)[1]
                                     integerValue]);
	}
	
	
	[self.memory addObject:numberToUse];
	[self.memory addObject:immediateStorage];
	
	
}

- (void) processCommandClass7 {
	// Class 7 of our instructions...
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	
	instructionToUse.fieldZero =
	[(self.currentSeperatedInstruction)[1] integerValue];
	
	instructionToUse.fieldOne =
	[(self.currentSeperatedInstruction)[2] integerValue];
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	[self.memory addObject:numberToUse];
	
	
}

- (void) processCommandClass8 {
	// Class 8
	id<VCInstructionDelegate> delegateToUse =
	[self.delegateCache delegateForTextualCode:self.command];
	
	int8_t opcodeToSet = [delegateToUse instructionOperationCode];
	
	VCInstruction *instructionToUse = [[VCInstruction alloc] init];
	instructionToUse.opCode = opcodeToSet;
	instructionToUse.fieldZero =
	[(self.currentSeperatedInstruction)[2] integerValue];
	
	NSNumber *numberToUse =
	@(instructionToUse.numericalRepresentation);
	
	NSNumber *immediateStorage =
	@([(self.currentSeperatedInstruction)[1]
                                 integerValue]);
	
	[self.memory addObject:numberToUse];
	[self.memory addObject:immediateStorage];
	
	
}

- (void) processCommandForLabelProcessing {
	// Label processing
	// We put it into our actual labels cache
	
	NSAssert(![self.actualLabelCache valueForKey:self.command], @"Label already exists!");
	
	NSNumber *labelAddress = [NSNumber numberWithInteger:self.memory.count];
	
	[self.actualLabelCache setValue:labelAddress forKey:self.command];
	
}

@end
