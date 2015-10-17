//
//  Pastels.m
//  Pastels
//
//  Created by Fabio Ritrovato on 17/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "Pastels.h"
#import <dlfcn.h>

@interface Pastels()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation Pastels

+ (void)pluginDidLoad:(NSBundle *)plugin
{
//    void *handle = dlopen("/usr/lib/libcycript.dylib", RTLD_NOW);
//    void (*listenServer)(short) = dlsym(handle, "CYListenServer");
//    (*listenServer)(54323);
    
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
//
        Class DVTLogAspect = objc_getClass("DVTLogAspect");
        [[DVTLogAspect performSelector:NSSelectorFromString(@"logAspectWithName:") withObject:@"IBLiveViews"] performSelector:NSSelectorFromString(@"setLogLevel:") withObject:@3];
        [[DVTLogAspect performSelector:NSSelectorFromString(@"logAspectWithName:") withObject:@"IBMessageChannel"] performSelector:NSSelectorFromString(@"setLogLevel:") withObject:@3];
        //        [[DVTLogAspect performSelector:NSSelectorFromString(@"logAspectWithName:") withObject:@"IBPlatformTool"] performSelector:NSSelectorFromString(@"setLogLevel:") withObject:@3];
    }
    return self;
}

@end

// -[IBLiveViewsManager _mainThread_filePathsContainingLiveClassesForProvider:]

//2015-10-13 19:29:40.180 Xcode[24063:675170] [MT] IBLiveViews: Ignoring invalid files because there are no live blueprints for <IBSourceCodeClassProvider: 0x6000001bc000> workspaceDocument=<IDEWorkspaceDocument: 0x119aaba90>: {(
//                                                                                                                                                                                                                                   <DVTFilePath:0x608000ac3100:'/Users/fabio/Dev/Pastels/Example/PastelsExample/PastelsExample/ViewController.h'>,
//                                                                                                                                                                                                                                   <DVTFilePath:0x608000ac3250:'/Users/fabio/Dev/Pastels/Example/PastelsExample/PastelsExample/MainPalette.m'>,
//                                                                                                                                                                                                                                   <DVTFilePath:0x608000ac28b0:'/Users/fabio/Dev/Pastels/Example/PastelsExample/PastelsExample/ViewController.m'>,
//                                                                                                                                                                                                                                   <DVTFilePath:0x608000ac2610:'/Users/fabio/Dev/Pastels/Example/PastelsExample/PastelsExample/AppDelegate.h'>,
//                                                                                                                                                                                                                                   <DVTFilePath:0x608000ac2760:'/Users/fabio/Dev/Pastels/Example/PastelsExample/PastelsExample/MainPalette.h'>,
//                                                                                                                                                                                                                                   <DVTFilePath:0x608000ac2f40:'/Users/fabio/Dev/Pastels/Example/PastelsExample/PastelsExample/AppDelegate.m'>
//                                                                                                                                                                                                                                   )}