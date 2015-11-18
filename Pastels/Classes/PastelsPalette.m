//
//  PastelsPalette.m
//  Pastels
//
//  Created by Fabio on 10/11/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "PastelsPalette.h"

@interface PastelsPalette()

@property (nonatomic) NSMutableDictionary<NSString *, id> *colors;
@property (nonatomic) IDEIndexClassSymbol *classSymbol;
@property (nonatomic, readwrite) NSString *objcClassName;

@end

@implementation PastelsPalette

+ (instancetype)paletteWithClassSymbol:(IDEIndexClassSymbol *)classSymbol
{
    PastelsPalette *palette = [self new];
    palette.classSymbol = classSymbol;
    palette.colors = [NSMutableDictionary new];
    palette.valid = NO;
    if ([classSymbol.resolution hasPrefix:@"s:"]) {
        //Swift mangled class name
        NSScanner *scanner = [NSScanner scannerWithString:[classSymbol.resolution substringFromIndex:2]];
        NSInteger length;
        NSString *moduleName;
        NSString *className;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
        [scanner scanInteger:&length];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&moduleName];
        [scanner scanInteger:&length];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet new] intoString:&className];
        palette.objcClassName = [NSString stringWithFormat:@"%@.%@", moduleName, className];
    } else {
        palette.objcClassName = classSymbol.name;
    }
    return palette;
}

- (void)invalidate
{
    self.valid = NO;
    self.name = nil;
    [self.colors removeAllObjects];
}

@end
