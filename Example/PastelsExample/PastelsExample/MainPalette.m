//
//  MainPalette.m
//  PastelsExample
//
//  Created by Fabio on 13/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "MainPalette.h"

@implementation MainPalette

+ (NSString *)paletteName
{
    return @"Main Brand Palette";
}

+ (UIColor *)logoMainColor
{
    return [UIColor redColor];
}

+ (UIColor *)logoSecondaryColor
{
    CGFloat r = 0.5f;
    CGFloat g = 0.7f;
    CGFloat b = 0.2f;
    CGFloat a = 1.0f;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)transparentLogoMainColor
{
    return [[MainPalette logoMainColor] colorWithAlphaComponent:0.6];
}

@end
