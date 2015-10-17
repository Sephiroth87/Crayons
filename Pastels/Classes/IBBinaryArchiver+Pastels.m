//
//  IBBinaryArchiver+Pastels.m
//  Pastels
//
//  Created by Fabio on 10/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBBinaryArchiver+Pastels.h"

NSString * const PastelsIBMessageSendChannelCustomParametersKey = @"PastelsIBMessageSendChannelCustomParametersKey";

@implementation IBBinaryArchiver (Pastels)

+ (void)load
{
    [self jr_swizzleMethod:@selector(initWithVersion:context:) withMethod:@selector(p_initWithVersion:context:) error:NULL];
}

- (id)p_initWithVersion:(long long)arg1 context:(id)arg2
{
    id result = [self p_initWithVersion:arg1 context:arg2];
    id parameters = [arg2 objectForKey:PastelsIBMessageSendChannelCustomParametersKey];
    if (parameters) {
        [self encodeInteger:1];
        [self encodeObject:parameters];
    }
    return result;
}

@end
