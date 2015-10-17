//
//  IBLiveViewsManager+Pastels.m
//  Pastels
//
//  Created by Fabio on 14/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBLiveViewsManager+Pastels.h"
#import "IDEFoundation.h"
#import "DVTFoundation.h"

@implementation IBLiveViewsManager (Pastels)

+ (void)load
{
    //    [self jr_swizzleMethod:@selector(sourceCodeClassProvider:didParseFilePaths:encounteringClassesNamed:) withMethod:@selector(p_sourceCodeClassProvider:didParseFilePaths:encounteringClassesNamed:) error:NULL];
    [self jr_swizzleMethod:@selector(_mainThread_filePathsContainingLiveClassesForProvider:) withMethod:@selector(p__mainThread_filePathsContainingLiveClassesForProvider:) error:NULL];
}

- (id)p__mainThread_filePathsContainingLiveClassesForProvider:(id)arg1
{
    NSMutableSet *result = [self p__mainThread_filePathsContainingLiveClassesForProvider:arg1];
    IDEWorkspace *workspace = [arg1 workspace];
    NSMutableDictionary *colorNamesForClasses = [NSMutableDictionary new];
    for (IDEIndexCallableSymbol *paletteNameMethod in [workspace.index allSymbolsMatchingNames:@[@"paletteName", @"paletteName()"] kind:[DVTSourceCodeSymbolKind classMethodSymbolKind]]) {
        //TODO: Check for methods returning strings
        IDEIndexClassSymbol *class = [paletteNameMethod containerSymbol];
        for (IDEIndexSymbol *definition in class.definitions) {
            [result addObject:[definition file]];
        }
    }
    return result;
}

@end
