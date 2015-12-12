//
//  NSObject+Crayons.h
//  Crayons
//
//  Created by Fabio Ritrovato on 12/12/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Crayons)

+ (void)c_swizzleMethod:(SEL)origSel ofClass:(Class)otherClass withMethod:(SEL)altSel;
+ (void)c_addMethod:(SEL)origSel toClass:(Class)otherClass;

@end
