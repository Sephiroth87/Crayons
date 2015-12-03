//
//  IBBinaryArchiver+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 10/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBBinaryArchiver+Crayons.h"

NSString * const CrayonsIBMessageSendChannelCustomParametersKey = @"CrayonsIBMessageSendChannelCustomParametersKey";

@implementation IBBinaryArchiver (Crayons)

+ (void)load
{
    [self jr_swizzleMethod:@selector(initWithVersion:context:) withMethod:@selector(p_initWithVersion:context:) error:NULL];
}

- (id)p_initWithVersion:(long long)arg1 context:(id)arg2
{
    id result = [self p_initWithVersion:arg1 context:arg2];
    id parameters = [arg2 objectForKey:CrayonsIBMessageSendChannelCustomParametersKey];
    if (parameters) {
        [self encodeInteger:1];
        [self encodeObject:parameters];
    }
    return result;
}

@end
