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
@property (nonatomic, readwrite, copy) NSString *className;
@property (nonatomic, readwrite, copy) NSString *categoryName;
@property (nonatomic, readwrite, copy) NSString *objcClassName;
@property (nonatomic, readwrite, copy) NSString *moduleName;

@end

@implementation CrayonsPalette

+ (instancetype)paletteWithSymbol:(IDEIndexSymbol *)symbol
{
    CrayonsPalette *palette = [self new];
    IDEIndexClassSymbol *classSymbol;
    if ([symbol isKindOfClass:[IDEIndexCategorySymbol class]]) {
        classSymbol = [(IDEIndexCategorySymbol *)symbol relatedClass];
        palette.categoryName = symbol.name;
    } else {
        classSymbol = (IDEIndexClassSymbol *)symbol;
    }
    palette.className = classSymbol.name;
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
        palette.moduleName = moduleName;
    } else {
        palette.objcClassName = classSymbol.name;
    }
    return palette;
}

- (void)invalidate
{
    self.valid = NO;
    self.name = nil;
    for (NSString *key in self.colors.allKeys) {
        self.colors[key] = [NSNull null];
    }
}

- (NSString *)fullName
{
    if (_name) {
        if (_categoryName) {
            return [NSString stringWithFormat:@"%@ (%@)", _name, _categoryName];
        }
        return _name;
    }
    return nil;
}

- (BOOL)isEqual:(id)object
{
    CrayonsPalette *other = (CrayonsPalette *)object;
    return [other.className isEqualToString:_className] && [[other fullName] isEqualToString:[self fullName]] && [other.colors isEqualToDictionary:_colors];
}

- (NSUInteger)hash
{
    return _className.hash ^ [self fullName].hash ^ _colors.hash;
}

@end
