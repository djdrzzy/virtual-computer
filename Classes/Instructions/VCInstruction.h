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

@class VCInstructionDelegateCache, VCMemory, VCRegisters;

@interface VCInstruction : NSObject

@property (nonatomic, readwrite, assign) int32_t numericalRepresentation;
@property (nonatomic, readwrite, unsafe_unretained) VCRegisters *registerTable;
@property (nonatomic, readwrite, unsafe_unretained) VCMemory *memoryTable;
@property (nonatomic, readwrite, weak) VCInstructionDelegateCache *delegateCache;

@property (nonatomic, readwrite) int8_t opCode;
@property (nonatomic, readwrite) int8_t fieldZero;
@property (nonatomic, readwrite) int8_t fieldOne;
@property (nonatomic, readwrite) int8_t fieldTwo;

/**
 * This initializes our instruction object with a numerical representation
 * of the object.
 * @param newNumericalRepresentation The new instruction fetched from memory.
 * @param registerTable The register table that the instruction will use when it executes.
 * @param memoryTable The memory table for the instruction.
 * @param delegateCache The delegate cache that we will look up how to run the instruction from.
 * @return The new instruction, ready to execute.
 */
-(id)initWithNumericalRepresentation:(int32_t)newNumericalRepresentation
					   registerTable:(VCRegisters*)registerTable
						 memoryTable:(VCMemory*)memoryTable
					   delegateCache:(VCInstructionDelegateCache*)delegateCache;

/**
 * This just returns a NOP instruction
 * @return the new instruction, ready to execute and do nothing.
 */
-(id)init;

/**
 * Runs our instruction.
 */
-(void)run;

/**
 * This clears the opCode field.
 */
-(void)clearOpCode;

/**
 * This clears field zero.
 */
-(void)clearFieldZero;

/**
 * This clears field One.
 */
-(void)clearFieldOne;

/**
 * This clears field two.
 */
-(void)clearFieldTwo;

@end

