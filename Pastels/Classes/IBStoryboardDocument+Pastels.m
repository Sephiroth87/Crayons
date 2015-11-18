//
//  IBStoryboardDocument+Pastels.m
//  Pastels
//
//  Created by Fabio on 13/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBStoryboardDocument+Pastels.h"
#import "IDEWorkspace+Pastels.h"

@implementation IBStoryboardDocument (Pastels)

+ (void)load
{
    [self jr_swizzleMethod:@selector(classDescriber:didModifyClasses:) withMethod:@selector(p_classDescriber:didModifyClasses:) error:NULL];
}

- (void)enableLiveViewsManagerIfNeeded
{
    IBLiveViewsManager *liveViewsManager = [self liveViewsManager];
    if (liveViewsManager && !liveViewsManager.isEnabled) {
        NSArray *palettes = [[self effectiveWorkspaceDocument] workspace].palettes;
        if (palettes.count) {
            DLog(@"🖍 LiveViewsManager enabled");
            liveViewsManager.enabled = YES;
            for (PastelsPalette *palette in palettes) {
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
            for (PastelsPalette *palette in palettes) {
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
