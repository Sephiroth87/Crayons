
//  IBSourceCodeClassProvider+Crayons.m
//  Crayons
//
//  Created by Fabio on 27/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IBSourceCodeClassProvider+Crayons.h"
#import "IDEWorkspace+Crayons.h"

@implementation IBSourceCodeClassProvider (Crayons)

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
