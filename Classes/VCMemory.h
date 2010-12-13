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

@class VCInstruction, VCVirtualComputer;

@interface VCMemory : NSObject

-(id) initWithAssociatedComputer:(VCVirtualComputer*)associatedComputer;

/**
 * We pass in the instruction values in this array, not the actual instructions remember.
 */
-(void)loadStateWithMemoryTable:(NSMutableArray*)newMemoryTable;

/**
 * This sets a memory address with the specified value. It wraps around the table
 * using modular arithmetic if the specified memory address is larger than the amount
 * of memory in the table.
 * @param theAddress the address to set.
 * @param theNewValue the value to set in the memory address.
 */
-(void)setMemoryAddress:(u_int32_t)theAddress withValue:(int32_t)theNewValue;

/**
 * This gets the value of a memory address. It wraps around the table using modular
 * arithmetic like in the setMemoryAddress method.
 * @param theAddress the memory address to get the value from.
 * @return the value of the supplied memory address.
 */
-(int)valueOfMemoryAddress:(u_int32_t)theAddress;

/**
 * This gets the value of a memory address. It wraps around the table using modular
 * arithmetic like in the setMemoryAddress method.
 * @param theAddress the memory address to get the value from.
 * @return the instruciton at the supplied memory address.
 */
-(VCInstruction*)instructionAtMemoryAddress:(u_int32_t)theAddress;

/**
 * Returns how many words are in our memory.
 */
-(u_int32_t) lengthOfAddressSpace;

/**
 * Returns the state of the memory table.
 */
-(NSArray*) state;

@end
