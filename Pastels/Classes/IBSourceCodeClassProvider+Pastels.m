
//  IBSourceCodeClassProvider+Pastels.m
//  Pastels
//
//  Created by Fabio on 27/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBSourceCodeClassProvider+Pastels.h"
#import "IDEWorkspace+Pastels.h"

@implementation IBSourceCodeClassProvider (Pastels)

+ (void)load
{
    [self jr_swizzleMethod:@selector(_notifyObserversOfAffectedFilePaths:andAffectedClassNames:) withMethod:@selector(p__notifyObserversOfAffectedFilePaths:andAffectedClassNames:) error:NULL];
}

- (void)p__notifyObserversOfAffectedFilePaths:(id)arg1 andAffectedClassNames:(id)arg2
{
    [self p__notifyObserversOfAffectedFilePaths:arg1 andAffectedClassNames:arg2];
    [self.workspace invalidatePalettesForClassNames:arg2];
}

@end
