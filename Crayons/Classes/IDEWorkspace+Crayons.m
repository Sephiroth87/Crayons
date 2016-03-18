//
//  IDEWorkspace+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 27/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IDEWorkspace+Crayons.h"
#import "DVTFoundation.h"
#import "IDEInterfaceBuilderKit.h"
#import <objc/runtime.h>

@interface IDEWorkspace ()

@property (nonatomic, readonly) NSMutableDictionary<NSString *, CrayonsPalette *> *palettesForClassNames;
@property (nonatomic) id indexNotificationObserver;

@end

@implementation IDEWorkspace (Crayons)

+ (void)load
{
    [self jr_swizzleMethod:@selector(didCreateIndex:) withMethod:@selector(c_didCreateIndex:) error:NULL];
}

- (void)dealloc
{
    if (self.indexNotificationObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.indexNotificationObserver];
    }
}

- (void)c_didCreateIndex:(id)index
{
    [self c_didCreateIndex:index];
    if (self.indexNotificationObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.indexNotificationObserver];
    }
    self.indexNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"IDEIndexDidIndexWorkspaceNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        if (notification.object == self.index) {
            DLog(@"🖍 updating palette classes");
            NSMutableDictionary *palettesForClassNames = self.palettesForClassNames;
            NSMutableArray *palettes = [[palettesForClassNames allValues] mutableCopy];
            NSMutableSet *currentClasses = [NSMutableSet setWithArray:[palettesForClassNames allKeys]];
            NSMutableSet *filePaths = [NSMutableSet set];
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
                        for (IDEIndexSymbolOccurrence *occurrence in [classSymbol occurrences]) {
                            [filePaths addObject:occurrence.file];
                        }
                        for (IDEIndexCategorySymbol *category in classSymbol.categories) {
                            if (category.isInProject && category.resolution.length) {
                                if ([currentClasses containsObject:category.resolution]) {
                                    [currentClasses removeObject:category.resolution];
                                } else {
                                    [palettesForClassNames setObject:[CrayonsPalette paletteWithCategorySymbol:category] forKey:category.resolution];
                                }
                            }
                            for (IDEIndexSymbolOccurrence *occurrence in [category occurrences]) {
                                [filePaths addObject:occurrence.file];
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
                    for (IDEIndexSymbolOccurrence *occurrence in [category occurrences]) {
                        [filePaths addObject:occurrence.file];
                    }
                }
            }
            for (NSString *oldClass in currentClasses) {
                DLog(@"🖍 removed old palette class %@", oldClass);
                [palettes removeObject:palettesForClassNames[oldClass]];
                [palettesForClassNames removeObjectForKey:oldClass];
            }
            if (palettesForClassNames.count) {
                IBLiveViewsManager *liveViewsManager = [NSClassFromString(@"IBLiveViewsManager") managerForWorkspace:self];
                if (liveViewsManager && !liveViewsManager.isEnabled) {
                    liveViewsManager.enabled = YES;
                    DLog(@"🖍 LiveViewsManager enabled");
                    [liveViewsManager invalidateBundleForDependenciesOfSourceFilesAtPaths:[filePaths allObjects] forceRebuild:NO];
                }
            }
        }
    }];
}

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
     
- (id)indexNotificationObserver
{
    return objc_getAssociatedObject(self, @selector(indexNotificationObserver));
}

- (void)setIndexNotificationObserver:(id)indexNotificationObserver
{
    objc_setAssociatedObject(self, @selector(indexNotificationObserver), indexNotificationObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<CrayonsPalette *> *)palettes
{
    return self.palettesForClassNames.allValues;
}

@end
