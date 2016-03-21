//
//  IDEWorkspace+Crayons.h
//  Crayons
//
//  Created by Fabio Ritrovato on 27/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IDEFoundation.h"
#import "CrayonsPalette.h"

@interface IDEWorkspace (Crayons)

@property (nonatomic, readonly) NSArray<CrayonsPalette *> *palettes;
@property (nonatomic, readonly) NSSet<DVTFilePath *> *palettesFilePaths;

- (void)invalidatePalettesForClassNames:(NSSet *)names;
- (void)updateColors:(NSArray<CrayonsPalette *> *)palettes;

@end
