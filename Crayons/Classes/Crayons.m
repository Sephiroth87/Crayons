//
//  Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 17/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "Crayons.h"
#import "DVTFoundation.h"

#import "IBSourceCodeClassProvider+Crayons.h"
#import "IBStoryboardDocument+Crayons.h"
#import "IBLiveViewsManager+Crayons.h"
#import "IBAbstractPlatformToolExecutionContext+Crayons.h"

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
            dispatch_async(dispatch_get_main_queue(), ^{
                // Classes from other Xcode plugins can't be swizzled until the plugin has been loaded,
                // so we use +initialize instead of +load and trigger it here
                // Also, we can't link to the plugin binary as that has some weird side effects,
                // so these classes are swizzled in a different way
                [CIBSourceCodeClassProvider class];
                [CIBStoryboardDocument class];
                [CIBLiveViewsManager class];
                [CIBAbstractPlatformToolExecutionContext class];
            });
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
        
        Class DVTLogAspect = objc_getClass("DVTLogAspect");
        [[DVTLogAspect performSelector:NSSelectorFromString(@"logAspectWithName:") withObject:@"IBLiveViews"] performSelector:NSSelectorFromString(@"setLogLevel:") withObject:@3];
        [[DVTLogAspect performSelector:NSSelectorFromString(@"logAspectWithName:") withObject:@"IBPlatformTool"] performSelector:NSSelectorFromString(@"setLogLevel:") withObject:@3];
        [[DVTLogAspect performSelector:NSSelectorFromString(@"logAspectWithName:") withObject:@"IBMessageChannel"] performSelector:NSSelectorFromString(@"setLogLevel:") withObject:@3];
    }
    return self;
}

@end
