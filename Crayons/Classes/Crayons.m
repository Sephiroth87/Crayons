//
//  Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 17/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "Crayons.h"

@interface Crayons()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation Crayons

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[Crayons alloc] initWithBundle:plugin];
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
        NSString *currentVersion = [plugin objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"CrayonsLastVersion"];
        if (lastVersion == nil || [lastVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
            [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"CrayonsLastVersion"];
        }
    }
    return self;
}

@end
