//
//  IBStoryboardDocument+Pastels.m
//  Pastels
//
//  Created by Fabio on 13/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBStoryboardDocument+Pastels.h"

@implementation IBStoryboardDocument (Pastels)

+ (void)load
{
//    [self jr_swizzleMethod:@selector(sourceCodeClassProvider:didParseFilePaths:encounteringClassesNamed:) withMethod:@selector(p_sourceCodeClassProvider:didParseFilePaths:encounteringClassesNamed:) error:NULL];
    [self jr_swizzleMethod:@selector(classDescriber:didModifyClasses:) withMethod:@selector(p_classDescriber:didModifyClasses:) error:NULL];
}

//- (void)p_sourceCodeClassProvider:(id)arg1 didParseFilePaths:(id)arg2 encounteringClassesNamed:(id)arg3
//{
//    [self p_sourceCodeClassProvider:arg1 didParseFilePaths:arg2 encounteringClassesNamed:arg3];
//}

- (void)p_classDescriber:(id)arg1 didModifyClasses:(id)arg2
{
    [self p_classDescriber:arg1 didModifyClasses:arg2];
    //TODO: Add smarter rules on when to enable/disable the manager
    [[self liveViewsManager] setEnabled:YES];
    for (NSString *class in arg2) {
        [[self liveViewsManager] invalidateBundleForClassNamed:class inDocument:self forceRebuild:NO];
    }
}

@end
