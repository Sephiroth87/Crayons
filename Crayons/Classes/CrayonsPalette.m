//
//  CrayonsPalette.m
//  Crayons
//
//  Created by Fabio Ritrovato on 10/11/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "CrayonsPalette.h"

@interface CrayonsPalette()

@property (nonatomic) NSMutableDictionary<NSString *, id> *colors;
@property (nonatomic) IDEIndexClassSymbol *classSymbol;
@property (nonatomic) IDEIndexCategorySymbol *categorySymbol;
@property (nonatomic, readwrite) NSString *objcClassName;

@end

@implementation CrayonsPalette

+ (instancetype)paletteWithClassSymbol:(IDEIndexClassSymbol *)classSymbol
{
    CrayonsPalette *palette = [self new];
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

+ (instancetype)paletteWithCategorySymbol:(IDEIndexCategorySymbol *)categorySymbol
{
    CrayonsPalette *palette = [self paletteWithClassSymbol:categorySymbol.relatedClass];
    palette.categorySymbol = categorySymbol;
    return palette;
}

- (void)invalidate
{
    self.valid = NO;
    self.name = nil;
    [self.colors removeAllObjects];
}

- (NSString *)fullName
{
    if (_name) {
        if (_categorySymbol) {
            return [NSString stringWithFormat:@"%@ (%@)", _name, _categorySymbol.name];
        }
        return _name;
    }
    return nil;
}

@end
