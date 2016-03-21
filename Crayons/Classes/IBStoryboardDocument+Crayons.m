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
}

- (void)p_classDescriber:(id)arg1 didModifyClasses:(id)arg2
{
    [self p_classDescriber:arg1 didModifyClasses:arg2];
    IDEWorkspace *workspace = [[self effectiveWorkspaceDocument] workspace];
    NSArray *palettes = workspace.palettes;
    IBLiveViewsManager *liveViewsManager = [self liveViewsManager];
    if (liveViewsManager && liveViewsManager.isEnabled) {
        for (CrayonsPalette *palette in palettes) {
            if ([arg2 containsObject:palette.className] && !palette.isValid) {
                DLog(@"🖍 invalidate bundle class %@", palette.className);
                [liveViewsManager invalidateBundleForClassNamed:palette.className inDocument:self forceRebuild:NO];
            }
        }
    }
}

@end
