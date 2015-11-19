//
//  IDEInterfaceBuilderKit.h
//  Crayons
//
//  Created by Fabio Ritrovato on 06/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IDEKit.h"

@interface IBDocument : NSDocument

- (id)effectiveWorkspaceDocument;
- (id)liveViewsManager;
- (void)classDescriber:(id)arg1 didModifyClasses:(id)arg2;

@end

@interface IBStoryboardDocument : IBDocument
@end

@interface IBInspectorViewController : IDEInspectorViewController

@property(readonly, nonatomic) IBDocument *inspectedDocument;

@end

@interface IBLiveViewsManager : NSObject

@property(nonatomic, getter=isEnabled) BOOL enabled;

- (id)cachedRequestProxyAttachingIfNeededWithDescription:(id)arg1 returningFailedLoadResult:(id *)arg2;
- (id)_mainThread_filePathsContainingLiveClassesForProvider:(id)arg1;
- (void)invalidateBundleForClassNamed:(id)arg1 inDocument:(id)arg2 forceRebuild:(BOOL)arg3;
- (void)_mainThread_rebuildBlueprint:(id)arg1 forSourceCodeCaseProvider:(id)arg2;

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

@interface IBAbstractWorkspaceDocumentClassProvider : NSObject

@property(readonly) IDEWorkspace *workspace;

@end

@interface IBSourceCodeClassProvider : IBAbstractWorkspaceDocumentClassProvider

- (void)_notifyObserversOfAffectedFilePaths:(id)arg1 andAffectedClassNames:(id)arg2;

@end
