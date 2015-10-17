//
//  DVTTask+Pastels.m
//  Pastels
//
//  Created by Fabio on 09/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "DVTTask+Pastels.h"
#import "Pastels.h"

@implementation DVTTask (Pastels)

+ (void)load
{
    [self jr_swizzleMethod:@selector(setLaunchPath:) withMethod:@selector(p_setLaunchPath:) error:NULL];
}

- (void)p_setLaunchPath:(NSString *)arg1
{
    [self p_setLaunchPath:arg1];
    if ([self.launchPath rangeOfString:@"IBDesignablesAgentCocoaTouch"].location != NSNotFound) {
        [self setValue:[[[Pastels sharedPlugin].bundle pathForResource:@"PastelsiOSSupport" ofType:@"framework"]stringByAppendingString:@"/PastelsiOSSupport"] forEnvironmentVariableNamed:@"DYLD_INSERT_LIBRARIES"];
    }
}

@end
