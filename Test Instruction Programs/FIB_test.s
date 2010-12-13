# Copyright (c) 2010 Daniel Drzimotta (djdrzzy@gmail.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


# The purpose of this program is to calculate the 20th fibonacci number.


# We use registers 0 and 1 to hold the last two calculated iterations.
REG 0
REG 1

# Register 2 holds the iteration that we are on
REG 1

# Register 3 holds the maximum number of iterations that we want to calculate
# So using 20 as the we will calculate the 20th fibonacci number, which is 6765
REG 20

# Register 4 will hold the final result. It is also used as some extra space to use for calculation
REG 0


# Our main loop
*FIB_LOOP

# Add the last two calculated fibonacci numbers together and store 
ADD 0 1 4

# Move register 1 to register 0 
XOR 0 0 0
ADD 0 1 0

# Move register 4 to register 1
XOR 1 1 1
ADD 4 1 1

# Update our iteration by adding 1
ADDI 2 1 2

# See if we just did our last iteration. If we didn't do another one
BNE 2 3 *FIB_LOOP


# Move our final result to register 4
XOR 4 4 4
ADD 1 4 4


HALT