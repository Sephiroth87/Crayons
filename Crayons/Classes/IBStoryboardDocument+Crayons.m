//
//  IBStoryboardDocument+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 13/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBStoryboardDocument+Crayons.h"
#import "IDEWorkspace+Crayons.h"

@implementation CIBStoryboardDocument

+ (void)initialize
{
    [self c_swizzleMethod:@selector(classDescriber:didModifyClasses:) ofClass:NSClassFromString(@"IBStoryboardDocument") withMethod:@selector(p_classDescriber:didModifyClasses:)];
    [self c_addMethod:@selector(enableLiveViewsManagerIfNeeded) toClass:NSClassFromString(@"IBStoryboardDocument")];
}

- (void)enableLiveViewsManagerIfNeeded
{
    IBLiveViewsManager *liveViewsManager = [self liveViewsManager];
    if (liveViewsManager && !liveViewsManager.isEnabled) {
        NSArray *palettes = [[self effectiveWorkspaceDocument] workspace].palettes;
        if (palettes.count) {
            DLog(@"🖍 LiveViewsManager enabled");
            liveViewsManager.enabled = YES;
            for (CrayonsPalette *palette in palettes) {
                [liveViewsManager invalidateBundleForClassNamed:palette.classSymbol.name inDocument:self forceRebuild:NO];
            }
        }
    }
}

- (void)p_classDescriber:(id)arg1 didModifyClasses:(id)arg2
{
    [self p_classDescriber:arg1 didModifyClasses:arg2];
    IDEWorkspace *workspace = [[self effectiveWorkspaceDocument] workspace];
    NSArray *palettes = workspace.palettes;
    IBLiveViewsManager *liveViewsManager = [self liveViewsManager];
    if (liveViewsManager) {
        if (liveViewsManager.isEnabled) {
            for (CrayonsPalette *palette in palettes) {
                NSString *className = palette.classSymbol.name;
                if ([arg2 containsObject:className] && !palette.isValid) {
                    DLog(@"🖍 invalidate bundle class %@", className);
                    [liveViewsManager invalidateBundleForClassNamed:className inDocument:self forceRebuild:NO];
                }
            }
        } else {
            if (palettes.count) {
                [self enableLiveViewsManagerIfNeeded];
            } else if (!liveViewsManager.isEnabled) {
                [workspace.index doWhenFilesReady:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enableLiveViewsManagerIfNeeded];
                    });
                }];
            }
        }
    }
}

@end
