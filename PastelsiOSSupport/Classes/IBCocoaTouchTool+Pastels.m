//
//  IBCocoaTouchTool+Pastels.m
//  Pastels
//
//  Created by Fabio Ritrovato on 09/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

@import UIKit;
#import <objc/runtime.h>
#import "IBCocoaTouchTool+Pastels.h"

@implementation IBCocoaTouchTool (Pastels)

- (NSDictionary *)palettesForClassesAndColorNames:(NSDictionary *)classesAndColorNames
{
    NSMutableDictionary *palettes = [NSMutableDictionary new];
    for (NSString *className in classesAndColorNames.allKeys) {
        NSMutableDictionary *palette = [NSMutableDictionary new];
        Class class = objc_getClass([className cStringUsingEncoding:NSUTF8StringEncoding]);
        //TODO: add swift support
        for (NSString *colorName in classesAndColorNames[className]) {
            if ([class respondsToSelector:NSSelectorFromString(colorName)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                UIColor *color = [class performSelector:NSSelectorFromString(colorName)];
#pragma clang diagnostic pop
                if ([color isKindOfClass:[UIColor class]]) {
                    NSLog(@"%@", color);
                    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
                    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB) {
                        CGFloat r, g, b, a;
                        if ([color getRed:&r green:&g blue:&b alpha:&a]) {
                            palette[colorName] = @{@"R": @(r), @"G": @(g), @"B": @(b), @"A": @(a)};
                        }
                    } else if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome) {
                        CGFloat w, a;
                        if ([color getWhite:&w alpha:&a]) {
                            palette[colorName] = @{@"W": @(w), @"A": @(a)};
                        }
                    }
                }
            }
        }
        if (palette.count) {
            palettes[className] = palette;
        }
    }
    return palettes;
}

@end
