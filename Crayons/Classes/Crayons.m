//
//  Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 17/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "Crayons.h"
#import "DVTFoundation.h"

NSString * const CrayonsNewVersionNotification = @"CrayonsNewVersionNotification";

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
        if (lastVersion == nil || [lastVersion compare:currentVersion options:NSNumericSearch] == NSOrderedAscending) {
            NSUserNotification *notification = [NSUserNotification new];
            notification.title = [NSString stringWithFormat:@"Crayons updated to %@", currentVersion];
            notification.informativeText = @"View release notes";
            notification.userInfo = @{CrayonsNewVersionNotification: @(YES)};
            notification.actionButtonTitle = @"View";
            [notification setValue:@YES forKey:@"_showsButtons"];
            [[DVTUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"CrayonsLastVersion"];
        }
//        [[NSUserDefaults standardUserDefaults] setObject:@"0.0" forKey:@"CrayonsLastVersion"];
    }
    return self;
}

@end
