//
//  IDEInterfaceBuilderKit.h
//  Pastels
//
//  Created by Fabio Ritrovato on 06/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IDEKit.h"

@interface IBDocument : NSDocument

- (id)liveViewsManager;
- (void)sourceCodeClassProvider:(id)arg1 didParseFilePaths:(id)arg2 encounteringClassesNamed:(id)arg3;
- (void)classDescriber:(id)arg1 didModifyClasses:(id)arg2;

@end

@interface IBStoryboardDocument : IBDocument
@end

@interface IBInspectorViewController : IDEInspectorViewController

@property(readonly, nonatomic) IBDocument *inspectedDocument;

@end

@interface IBLiveViewsManager : NSObject

@property(nonatomic, getter=isEnabled) BOOL enabled;

- (id)cachedRequestProxyAttachingIfNeededForTargetRuntime:(id)arg1 scaleFactor:(id)arg2 backgroundOperationIdentifier:(id)arg3 queue:(id)arg4 returningFailedLoadResult:(id *)arg5;
- (id)cachedRequestProxyAttachingIfNeededWithDescription:(id)arg1 returningFailedLoadResult:(id *)arg2;
- (id)_mainThread_filePathsContainingLiveClassesForProvider:(id)arg1;
- (void)invalidateBundleForClassNamed:(id)arg1 inDocument:(id)arg2 forceRebuild:(BOOL)arg3;

@end

@interface IBAbstractPlatformToolProxy : NSObject

- (id)sendMessage:(SEL)arg1 toChannelDuring:(BOOL (^)(SEL arg1, id arg2, id *arg3))arg2;

@end

@interface IBPlatformToolLaunchContext : NSObject

@property(readonly, nonatomic) NSString *toolName;

@end

@interface IBAbstractPlatformToolExecutionContext : NSObject

- (BOOL)populateEnvironment:(id)arg1 launchContext:(id)arg2 error:(id *)arg3;

@end
