//
//  GooglePalette.m
//  CrayonsExample
//
//  Created by Fabio Ritrovato on 03/12/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "GooglePalette.h"

@implementation GooglePalette

// You can also use C functions internally
UIColor *colorFromRGB(NSInteger rgbValue) {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

+ (UIColor *)red
{
    return colorFromRGB(0xF44336);
}

+ (UIColor *)pink
{
    return colorFromRGB(0xE91E63);
}

+ (UIColor *)purple
{
    return colorFromRGB(0x9C27B0);
}

+ (UIColor *)deepPurple
{
    return colorFromRGB(0x673AB7);
}

+ (UIColor *)indigo
{
    return colorFromRGB(0x3F51B5);
}

+ (UIColor *)blue
{
    return colorFromRGB(0x2196F3);
}

+ (UIColor *)lightBlue
{
    return colorFromRGB(0x03A9F4);
}

+ (UIColor *)cyan
{
    return colorFromRGB(0x00BCD4);
}

+ (UIColor *)teal
{
    return colorFromRGB(0x009688);
}

+ (UIColor *)green
{
    return colorFromRGB(0x4CAF50);
}

+ (UIColor *)lightGreen
{
    return colorFromRGB(0x8BC34A);
}

+ (UIColor *)lime
{
    return colorFromRGB(0xCDDC39);
}

+ (UIColor *)yellow
{
    return colorFromRGB(0xFFEB3B);
}

+ (UIColor *)amber
{
    return colorFromRGB(0xFFC107);
}

+ (UIColor *)orange
{
    return colorFromRGB(0xFF9800);
}

+ (UIColor *)deepOrange
{
    return colorFromRGB(0xFF5722);
}

+ (UIColor *)brown
{
    return colorFromRGB(0x795548);
}

+ (UIColor *)grey
{
    return colorFromRGB(0x9E9E9E);
}

+ (UIColor *)blueGrey
{
    return colorFromRGB(0x607D8B);
}

+ (UIColor *)black
{
    return colorFromRGB(0x000000);
}

+ (UIColor *)white
{
    return colorFromRGB(0xFFFFFF);
}

+ (NSString *)paletteName
{
    return @"Google Material Palette";
}

@end
