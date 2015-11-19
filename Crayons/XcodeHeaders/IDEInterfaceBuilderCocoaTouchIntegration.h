//
//  IDEInterfaceBuilderCocoaTouchIntegration.h
//  Crayons
//
//  Created by Fabio Ritrovato on 07/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IDEInterfaceBuilderKit.h"

@interface IBCocoaTouchTargetRuntime : NSObject
@end

@interface IBMessageChannelCocoaTouchToolProxy: NSObject

- (id)channel;

@end

@interface NSThread (IBCocoaTouchToolAdditions)

- (id)cocoaTouchToolForTargetRuntime:(id)arg1;

@end

@interface IBDocument (IBDocumentCocoaTouchIntegration)

- (id)cocoaTouchTargetRuntime;

@end

@interface IBCocoaTouchPlatformToolDescription : NSObject

- (id)initWithTargetRuntime:(id)arg1 role:(long long)arg2 scaleFactor:(double)arg3;

@end

@interface IBCocoaTouchToolProxy : IBAbstractPlatformToolProxy
@end
