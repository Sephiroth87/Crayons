//
//  NSObject+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 12/12/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "NSObject+Crayons.h"
#import <objc/objc-class.h>

@implementation NSObject (Crayons)

+ (void)c_swizzleMethod:(SEL)origSel ofClass:(Class)otherClass withMethod:(SEL)altSel {
    Method origMethod = class_getInstanceMethod(otherClass, origSel);
    Method altMethod = class_getInstanceMethod(self, altSel);
    class_addMethod(otherClass,
                    origSel,
                    class_getMethodImplementation(otherClass, origSel),
                    method_getTypeEncoding(origMethod));
    class_addMethod(otherClass,
                    altSel,
                    class_getMethodImplementation(self, altSel),
                    method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(otherClass, origSel), class_getInstanceMethod(otherClass, altSel));
}

+ (void)c_addMethod:(SEL)origSel toClass:(Class)otherClass {
    Method origMethod = class_getInstanceMethod(self, origSel);
    class_addMethod(otherClass,
                    origSel,
                    class_getMethodImplementation(self, origSel),
                    method_getTypeEncoding(origMethod));
}

@end
