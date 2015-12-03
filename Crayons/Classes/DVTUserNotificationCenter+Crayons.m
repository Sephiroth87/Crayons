//
//  DVTUserNotificationCenter+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 03/12/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "DVTUserNotificationCenter+Crayons.h"
#import "Crayons.h"

@implementation DVTUserNotificationCenter (Crayons)

+ (void)load
{
    NSError *error = nil;
    [self jr_swizzleMethod:@selector(userNotificationCenter:shouldPresentNotification:) withMethod:@selector(vvfc_userNotificationCenter:shouldPresentNotification:) error:&error];
    [self jr_swizzleMethod:@selector(userNotificationCenter:didActivateNotification:) withMethod:@selector(vvfc_userNotificationCenter:didActivateNotification:) error:&error];
}

- (BOOL)vvfc_userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    if ([notification.userInfo[CrayonsNewVersionNotification] boolValue]) {
        return YES;
    }
    return [self vvfc_userNotificationCenter:center shouldPresentNotification:notification];
}

- (void)vvfc_userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if ([notification.userInfo[CrayonsNewVersionNotification] boolValue]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Sephiroth87/Crayons#release-notes"]];
    }
    [self vvfc_userNotificationCenter:center didActivateNotification:notification];
}

@end
