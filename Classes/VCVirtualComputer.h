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

@interface VCVirtualComputer : NSObject
@property (nonatomic, readwrite, retain) VCRegisters                  *registerTable;
@property (nonatomic, readwrite, retain) VCMemory                     *memoryTable;
@property (nonatomic, readwrite, retain) VCInstructionDelegateCache   *delegateCache;
@property (nonatomic, readwrite, assign) int32_t                      cyclesToRun;
/**
 * This loads the state from a plist.
 */
-(void) loadState:(NSDictionary*)newState;

/**
 * This returns the state of the computer in our plist format.
 */
-(NSDictionary*)state;

/**
 * Here we start our computing! We will continue forever if our cyclesToRun is <0.
 */
-(void) compute;

/**
 * Here we do a step through our ram. It runs the instruction where
 * the current program counter is pointing too and then increments
 * the program counter. It also checks the instruction to make sure
 * it is of the right type, as that can change if loads and stores
 * are done.
 */
-(void) clockTick;


/**
 * Returns how many words of memory our computer has.
 */
-(u_int32_t) lengthOfAddressSpace;

@end