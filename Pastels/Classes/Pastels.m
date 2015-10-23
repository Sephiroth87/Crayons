//
//  Pastels.m
//  Pastels
//
//  Created by Fabio Ritrovato on 17/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "Pastels.h"

@interface Pastels()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation Pastels

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[Pastels alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        self.bundle = plugin;
    }
    return self;
}

@end
