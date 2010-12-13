//
//  VCInstructionBaseDelegate.h
//  Virtual Computer
//
//  Created by Daniel Drzimotta on 09-09-26.
//  Copyright 2009 Daniel Drzimotta. All rights reserved.
//

#import "VCInstructionDelegate.h"

@interface VCInstructionBaseDelegate : NSObject <VCInstructionDelegate> {

}

+ (VCInstructionBaseDelegate*) sharedInstance;

@end
