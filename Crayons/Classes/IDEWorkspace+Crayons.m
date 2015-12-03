//
//  IDEWorkspace+Crayons.m
//  Crayons
//
//  Created by Fabio on 27/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IDEWorkspace+Crayons.h"
#import "DVTFoundation.h"
#import <objc/runtime.h>

@interface IDEWorkspace ()

@property (nonatomic, readonly) NSMutableDictionary<NSString *, CrayonsPalette *> *palettesForClassNames;

@end

@implementation IDEWorkspace (Crayons)

- (void)invalidatePalettesForClassNames:(NSArray *)names
{
    NSMutableDictionary *palettesForClassNames = self.palettesForClassNames;
    for (NSString *name in names) {
        if ([palettesForClassNames objectForKey:name]) {
        DLog(@"🖍 invalidated palette for class %@", name);
            CrayonsPalette *palette = palettesForClassNames[name];
            [palette invalidate];
        }
    }
}

- (void)updateColors:(NSArray<CrayonsPalette *> *)palettes
{
    for (CrayonsPalette *palette in palettes) {
        NSMutableSet *currentColors = [[palette.colors allKeys] mutableCopy];
        id methods = palette.categorySymbol ? [palette.categorySymbol classMethods] : [palette.classSymbol classMethods];
        for (IDEIndexCallableSymbol *method in methods) {
            NSString *methodName = method.name;
            if (([[[method returnType] name] isEqualToString:@"UIColor"] || [[method resolution] hasSuffix:@"UIColor"]) && [method numArguments] == 0) {
                if ([methodName hasSuffix:@"()"]) {
                    methodName = [methodName substringToIndex:methodName.length - 2];
                }
                if ([currentColors containsObject:methodName]) {
                    [currentColors removeObject:methodName];
                } else {
                    palette.colors[methodName] = [NSNull null];
                }
            }
        }
        for (NSString *oldColor in currentColors) {
            DLog(@"🖍 removed old color %@ in palette class %@", oldColor, palette.classSymbol.name);
            [palette.colors removeObjectForKey:oldColor];
        }
    }
}

#pragma mark - Properties

- (NSMutableDictionary *)palettesForClassNames
{
    NSMutableDictionary *palettesForClassNames = objc_getAssociatedObject(self, @selector(palettesForClassNames));
    if (!palettesForClassNames) {
        palettesForClassNames = [NSMutableDictionary new];
        objc_setAssociatedObject(self, @selector(palettesForClassNames), palettesForClassNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return palettesForClassNames;
}

- (NSArray<CrayonsPalette *> *)palettes
{
    DLog(@"🖍 updating palette classes");
    NSMutableDictionary *palettesForClassNames = self.palettesForClassNames;
    NSMutableArray *palettes = [[palettesForClassNames allValues] mutableCopy];
    NSMutableSet *currentClasses = [NSMutableSet setWithArray:[palettesForClassNames allKeys]];
    for (IDEIndexCallableSymbol *paletteNameMethod in [self.index allSymbolsMatchingNames:@[@"paletteName", @"paletteName()"] kind:[DVTSourceCodeSymbolKind classMethodSymbolKind]]) {
        if (([[[paletteNameMethod returnType] name] isEqualToString:@"NSString"] || [paletteNameMethod.resolution hasSuffix:@"NSString"] || [paletteNameMethod.resolution hasSuffix:@"_SS"]) && [paletteNameMethod numArguments] == 0) {
            IDEIndexClassSymbol *classSymbol = [paletteNameMethod containerSymbol];
            if (classSymbol.isInProject) {
                NSString *className = classSymbol.name;
                if ([currentClasses containsObject:className]) {
                    [currentClasses removeObject:className];
                } else {
                    [palettesForClassNames setObject:[CrayonsPalette paletteWithClassSymbol:classSymbol] forKey:className];
                }
                for (IDEIndexCategorySymbol *category in classSymbol.categories) {
                    if (category.isInProject && category.resolution.length) {
                        if ([currentClasses containsObject:category.resolution]) {
                            [currentClasses removeObject:category.resolution];
                        } else {
                            [palettesForClassNames setObject:[CrayonsPalette paletteWithCategorySymbol:category] forKey:category.resolution];
                        }
                    }
                }
            }
        }
    }
    for (IDEIndexClassSymbol *class in [self.index allSymbolsMatchingNames:@[@"UIColor"] kind:[DVTSourceCodeSymbolKind classSymbolKind]]) {
        for (IDEIndexCategorySymbol *category in class.categories) {
            if (category.isInProject && category.resolution.length) {
                if ([currentClasses containsObject:category.resolution]) {
                    [currentClasses removeObject:category.resolution];
                } else {
                    [palettesForClassNames setObject:[CrayonsPalette paletteWithCategorySymbol:category] forKey:category.resolution];
                }
            }
        }
    }
    for (NSString *oldClass in currentClasses) {
        DLog(@"🖍 removed old palette class %@", oldClass);
        [palettes removeObject:palettesForClassNames[oldClass]];
        [palettesForClassNames removeObjectForKey:oldClass];
    }
    return palettes;
}

@end
