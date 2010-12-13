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

#import <Cocoa/Cocoa.h>

@class VCVirtualComputer;

@interface VCRegisters : NSObject

@property (nonatomic, assign) u_int32_t           programCounter;
@property (nonatomic, assign) BOOL                haltedFlag;

/**
 * The designated initializer.
 */
-(id) initWithAssociatedComputer:(VCVirtualComputer*)associatedComputer;

/**
 * Advances our program counter. If it is beyond the edge of memory it wraps around.
 */
-(void)advanceProgramCounter;

/**
 * This resets all registers to 0.
 */
-(void)reset;

/**
 * This sets a register with the specified value. It wraps around the table
 * using modular arithmetic if the specified register is larger than the amount
 * of registers in the table.
 * @param theRegister the register to set.
 * @param theNewValue the value to set in the register.
 */
-(void)setValueOfRegister:(NSUInteger)theRegister withValue:(int)theNewValue;

/**
 * This gets the value of a register. It wraps around the table using modular
 * arithmetic like in the setRegister method.
 * @param theRegister the register to get the value from.
 * @return the value of the supplied register.
 */
-(int)valueOfRegister:(NSUInteger)theRegister;

/**
 * This fetches the value of the input register. It 'pops' the value from the input string.
 * @return the value that was fetched from the input register.
 */
-(int) valueOfInputRegister;

/**
 * Pushes the supplied value to the output register.
 * @param valueToPush the value to push.
 */
-(void) setValueOfOutputRegister:(int)valueToPush;

/**
 * Returns the state of the registers.
 */
-(NSDictionary*) state;

/**
 * This loads the state of the registers.
 */
-(void) loadStateWithRegisterTable:(NSDictionary*)state;

@end