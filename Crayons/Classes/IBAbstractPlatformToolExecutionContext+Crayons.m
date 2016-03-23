//
//  IBAbstractPlatformToolExecutionContext+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 09/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBAbstractPlatformToolExecutionContext+Crayons.h"
#import "Crayons.h"

@implementation CIBAbstractPlatformToolExecutionContext

+ (void)initialize
{
    [self c_swizzleMethod:@selector(populateEnvironment:launchContext:error:) ofClass:NSClassFromString(@"IBAbstractPlatformToolExecutionContext") withMethod:@selector(p_populateEnvironment:launchContext:error:)];
}

- (BOOL)p_populateEnvironment:(id)arg1 launchContext:(id)arg2 error:(id *)arg3
{
    BOOL result = [self p_populateEnvironment:arg1 launchContext:arg2 error:arg3];
    DLog(@"🖍 Launching: %@", [arg2 toolName]);
    if ([[arg2 toolName] isEqualToString:@"IBDesignablesAgentCocoaTouch"]) {
        [arg1 setValue:[[[Crayons sharedPlugin].bundle pathForResource:@"CrayonsiOSSupport" ofType:@"framework"] stringByAppendingString:@"/CrayonsiOSSupport"] forKey:@"DYLD_INSERT_LIBRARIES"];
    }
    return result;
}

@end
