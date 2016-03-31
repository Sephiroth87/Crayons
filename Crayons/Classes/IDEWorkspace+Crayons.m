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

@property (nonatomic, readonly) NSMutableDictionary<NSString *, CrayonsPalette *> *palettesForResolutions;
@property (nonatomic, readwrite) NSSet<DVTFilePath *> *palettesFilePaths;
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
            [self updatePalettes];
        }
    }];
    [self updatePalettes];
}

- (void)updatePalettes
{
    DLog(@"🖍 updating palette classes");
    NSMutableDictionary *palettesForResolutions = self.palettesForResolutions;
    NSMutableArray *palettes = [[palettesForResolutions allValues] mutableCopy];
    NSMutableSet *currentResolutions = [NSMutableSet setWithArray:[palettesForResolutions allKeys]];
    NSMutableSet *filePaths = [NSMutableSet set];
    
    void (^handleSymbol)(IDEIndexSymbol *) = ^void (IDEIndexSymbol *symbol) {
        if (symbol.isInProject && symbol.resolution.length) {
            CrayonsPalette *palette = palettesForResolutions[symbol.resolution] ?: [CrayonsPalette paletteWithSymbol:symbol];
            [currentResolutions removeObject:symbol.resolution];
            if ([symbol isKindOfClass:[IDEIndexClassSymbol class]]) {
                [self updateColors:palette symbols:((IDEIndexClassSymbol *)symbol).children];
            } else if ([symbol isKindOfClass:[IDEIndexCategorySymbol class]]) {
                [self updateColors:palette symbols:((IDEIndexCategorySymbol *)symbol).children];
            }
            palettesForResolutions[symbol.resolution] = palette;
            for (IDEIndexSymbolOccurrence *occurrence in [symbol occurrences]) {
                [filePaths addObject:occurrence.file];
            }
        }
    };
    
    for (IDEIndexCallableSymbol *paletteNameMethod in [self.index allSymbolsMatchingNames:@[@"paletteName", @"paletteName()"] kind:[DVTSourceCodeSymbolKind classMethodSymbolKind]]) {
        if (([[[paletteNameMethod returnType] name] isEqualToString:@"NSString"] || [paletteNameMethod.resolution hasSuffix:@"NSString"] || [paletteNameMethod.resolution hasSuffix:@"_SS"]) && [paletteNameMethod numArguments] == 0) {
            IDEIndexClassSymbol *classSymbol = [paletteNameMethod containerSymbol];
            handleSymbol(classSymbol);
            for (IDEIndexCategorySymbol *category in classSymbol.categories) {
                handleSymbol(category);
            }
        }
    }
    for (IDEIndexClassSymbol *class in [self.index allSymbolsMatchingNames:@[@"UIColor"] kind:[DVTSourceCodeSymbolKind classSymbolKind]]) {
        for (IDEIndexCategorySymbol *category in class.categories) {
            handleSymbol(category);
        }
    }
    for (NSString *oldClass in currentResolutions) {
        DLog(@"🖍 removed old palette class %@", oldClass);
        [palettes removeObject:palettesForResolutions[oldClass]];
        [palettesForResolutions removeObjectForKey:oldClass];
    }
    self.palettesFilePaths = filePaths;
    if (palettesForResolutions.count) {
        IBLiveViewsManager *liveViewsManager = [NSClassFromString(@"IBLiveViewsManager") managerForWorkspace:self];
        if (liveViewsManager && !liveViewsManager.isEnabled) {
            liveViewsManager.enabled = YES;
            DLog(@"🖍 LiveViewsManager enabled");
            [liveViewsManager invalidateBundleForDependenciesOfSourceFilesAtPaths:[filePaths allObjects] forceRebuild:NO];
        }
    }
}

- (void)invalidatePalettesForClassNames:(NSArray *)names
{
    for (CrayonsPalette *palette in self.palettes) {
        if ([names containsObject:palette.className]) {
            DLog(@"🖍 invalidated palette for class %@", palette.className);
            [palette invalidate];
        }
    }
}

- (void)updateColors:(CrayonsPalette *)palette symbols:(id)symbols
{
    NSMutableSet *currentColors = [[palette.colors allKeys] mutableCopy];
    for (IDEIndexSymbol *symbol in symbols) {
        if (symbol.symbolKind == [DVTSourceCodeSymbolKind classMethodSymbolKind]) {
            IDEIndexCallableSymbol *method = (IDEIndexCallableSymbol *)symbol;
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
            } else if ([[method resolution] hasSuffix:@"ERR"]) {
                // Sometimes the index gets corrupted, so we recreate it from scratch
                //TODO: is there a better way to detect this? It looks like the index stops updating on corruption, so what happens
                // if it's other methods that are corrupted instead of the ones we use?
                [self.index _reopenDatabaseWithRemoval:YES];
                DLog(@"🖍 Index corruption detected with %@, rebuilding", [method resolution]);
            }
        } else if ([symbol.symbolKind.identifier isEqualToString:@"Xcode.SourceCodeSymbolKind.ClassProperty"]) {
            if ([[symbol resolution] hasSuffix:@"UIColor"]) {
                if ([currentColors containsObject:symbol.name]) {
                    [currentColors removeObject:symbol.name];
                } else {
                    palette.colors[symbol.name] = [NSNull null];
                }
            }
        }
    }
    for (NSString *oldColor in currentColors) {
        DLog(@"🖍 removed old color %@ in palette class %@", oldColor, palette.className);
        [palette.colors removeObjectForKey:oldColor];
    }
}

#pragma mark - Properties

- (NSMutableDictionary *)palettesForResolutions
{
    NSMutableDictionary *palettesForResolutions = objc_getAssociatedObject(self, @selector(palettesForResolutions));
    if (!palettesForResolutions) {
        palettesForResolutions = [NSMutableDictionary new];
        objc_setAssociatedObject(self, @selector(palettesForResolutions), palettesForResolutions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return palettesForResolutions;
}
     
- (id)indexNotificationObserver
{
    return objc_getAssociatedObject(self, @selector(indexNotificationObserver));
}

- (void)setIndexNotificationObserver:(id)indexNotificationObserver
{
    objc_setAssociatedObject(self, @selector(indexNotificationObserver), indexNotificationObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSSet<DVTFilePath *> *)palettesFilePaths
{
    return objc_getAssociatedObject(self, @selector(palettesFilePaths));
}

- (void)setPalettesFilePaths:(NSSet<DVTFilePath *> *)palettesFilePaths
{
    objc_setAssociatedObject(self, @selector(palettesFilePaths), palettesFilePaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<CrayonsPalette *> *)palettes
{
    return self.palettesForResolutions.allValues;
}

@end
