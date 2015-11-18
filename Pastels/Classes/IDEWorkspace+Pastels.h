//
//  IDEWorkspace+Pastels.h
//  Pastels
//
//  Created by Fabio on 27/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IDEFoundation.h"
#import "PastelsPalette.h"

@interface IDEWorkspace (Pastels)

@property (nonatomic, readonly) NSArray<PastelsPalette *> *palettes;

- (void)invalidatePalettesForClassNames:(NSSet *)names;
- (void)updateColors:(NSArray<PastelsPalette *> *)palettes;

@end
