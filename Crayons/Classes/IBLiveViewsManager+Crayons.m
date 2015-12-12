//
//  IBLiveViewsManager+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 14/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBLiveViewsManager+Crayons.h"
#import "IDEWorkspace+Crayons.h"
#import "IDEFoundation.h"
#import "DVTFoundation.h"

@implementation CIBLiveViewsManager

+ (void)initialize
{
    [self c_swizzleMethod:@selector(_mainThread_filePathsContainingLiveClassesForProvider:) ofClass:NSClassFromString(@"IBLiveViewsManager") withMethod:@selector(p__mainThread_filePathsContainingLiveClassesForProvider:)];
    [self c_swizzleMethod:@selector(_mainThread_rebuildBlueprint:forSourceCodeCaseProvider:) ofClass:NSClassFromString(@"IBLiveViewsManager") withMethod:@selector(p__mainThread_rebuildBlueprint:forSourceCodeCaseProvider:)];
}

- (id)p__mainThread_filePathsContainingLiveClassesForProvider:(id)arg1
{
    NSMutableSet *result = [self p__mainThread_filePathsContainingLiveClassesForProvider:arg1];
    IDEWorkspace *workspace = ((IBSourceCodeClassProvider *)arg1).workspace;
    for (CrayonsPalette *palette in workspace.palettes) {
        IDEIndexCollection *definitions = palette.categorySymbol ? palette.categorySymbol.definitions : palette.classSymbol.definitions;
        for (IDEIndexSymbol *definition in definitions) {
            [result addObject:[definition file]];
        }
    }
    return result;
}

- (void)p__mainThread_rebuildBlueprint:(id)arg1 forSourceCodeCaseProvider:(id)arg2
{
    [self p__mainThread_rebuildBlueprint:arg1 forSourceCodeCaseProvider:arg2];
    IDEWorkspace *workspace = ((IBSourceCodeClassProvider *)arg2).workspace;
    for (CrayonsPalette *palette in workspace.palettes) {
        if (!palette.isValid) {
            [palette invalidate];
            palette.valid = YES;
        }
    }
}

@end
