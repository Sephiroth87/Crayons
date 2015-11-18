//
//  PastelsPalette.h
//  Pastels
//
//  Created by Fabio on 10/11/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDEFoundation.h"

@class PastelsColor;

@interface PastelsPalette : NSObject

@property (nonatomic, readonly) NSMutableDictionary<NSString *, id> *colors;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *objcClassName;
@property (nonatomic, readonly) IDEIndexClassSymbol *classSymbol;
@property (assign, getter=isValid) BOOL valid;

+ (instancetype)paletteWithClassSymbol:(IDEIndexClassSymbol *)classSymbol;
- (void)invalidate;

@end
