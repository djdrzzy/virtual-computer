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

# Tests BGT
#
# Usage: BGT r1 r2 c1
#
# IF r1 > r2 THEN PC = c1 ELSE PC = PC + 2

# This one is kinda tricky. We compare the two registers r1 and r2. We then jump to the CONSTANT
# c1. Now c1 can be described as either a plain integer, or it can be a label of the form *LABEL.



REG 9
REG 8
REG 16
REG 7

BGT 0 1 *GOODJUMP
HALT

*GOODJUMP
BGT 1 2 *BADJUMP
ADDI 3 14 3
HALT

*BADJUMP
ADDI 3 -7 3
HALT


# HALT!!!
# REG 0 should equal 9
# REG 1 should equal 8
# REG 2 should equal 16
# REG 3 should equal 21
HALT