//
//  IBCocoaTouchTool+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 09/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

@import UIKit;
#import <objc/runtime.h>
#import "IBCocoaTouchTool+Crayons.h"

@implementation IBCocoaTouchTool (Crayons)

- (NSDictionary *)paletteNamesForClassNames:(NSArray *)classNames
{
    NSMutableDictionary *paletteNames = [NSMutableDictionary new];
    for (NSString *className in classNames) {
        Class class = objc_getClass([className cStringUsingEncoding:NSUTF8StringEncoding]);
        if ([class respondsToSelector:NSSelectorFromString(@"paletteName")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString *paletteName = [class performSelector:NSSelectorFromString(@"paletteName")];
#pragma clang diagnostic pop
            if ([paletteName isKindOfClass:[NSString class]]) {
                paletteNames[className] = paletteName;
            }
        }
    }
    return paletteNames;
}

- (NSDictionary *)colorsForClassesAndColorNames:(NSDictionary *)classesAndColorNames
{
    NSMutableDictionary *colors = [NSMutableDictionary new];
    for (NSString *className in classesAndColorNames.allKeys) {
        NSMutableDictionary *classColors = [NSMutableDictionary new];
        Class class = objc_getClass([className cStringUsingEncoding:NSUTF8StringEncoding]);
        for (NSString *colorName in classesAndColorNames[className]) {
            if ([class respondsToSelector:NSSelectorFromString(colorName)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                UIColor *color = [class performSelector:NSSelectorFromString(colorName)];
#pragma clang diagnostic pop
                if ([color isKindOfClass:[UIColor class]]) {
                    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
                    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB) {
                        CGFloat r, g, b, a;
                        if ([color getRed:&r green:&g blue:&b alpha:&a]) {
                            classColors[colorName] = @{@"R": @(r), @"G": @(g), @"B": @(b), @"A": @(a)};
                        }
                    } else if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome) {
                        CGFloat w, a;
                        if ([color getWhite:&w alpha:&a]) {
                            classColors[colorName] = @{@"W": @(w), @"A": @(a)};
                        }
                    }
                }
            }
        }
        if (classColors.count) {
            colors[className] = classColors;
        }
    }
    return colors;
}

@end
