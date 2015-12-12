//
//  IDEInterfaceBuilderKit.h
//  Crayons
//
//  Created by Fabio Ritrovato on 06/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "IDEKit.h"

@protocol IBDocument <NSObject>

@optional

- (id)effectiveWorkspaceDocument;
- (id)liveViewsManager;
- (void)classDescriber:(id)arg1 didModifyClasses:(id)arg2;

@end

@interface IBDocument : NSDocument <IBDocument>
@end

@protocol IBStoryboardDocument <IBDocument>
@end

@interface IBStoryboardDocument : IBDocument <IBStoryboardDocument>
@end

@interface IBInspectorViewController : IDEInspectorViewController

@property(readonly, nonatomic) IBDocument *inspectedDocument;

@end

@protocol IBLiveViewsManager <NSObject>

@optional

@property(nonatomic, getter=isEnabled) BOOL enabled;

- (id)cachedRequestProxyAttachingIfNeededWithDescription:(id)arg1 returningFailedLoadResult:(id *)arg2;
- (id)_mainThread_filePathsContainingLiveClassesForProvider:(id)arg1;
- (void)invalidateBundleForClassNamed:(id)arg1 inDocument:(id)arg2 forceRebuild:(BOOL)arg3;
- (void)_mainThread_rebuildBlueprint:(id)arg1 forSourceCodeCaseProvider:(id)arg2;

@end

@interface IBLiveViewsManager : NSObject <IBLiveViewsManager>
@end

@interface IBAbstractPlatformToolProxy : NSObject

- (id)sendMessage:(SEL)arg1 toChannelDuring:(BOOL (^)(SEL arg1, id arg2, id *arg3))arg2;

@end

@interface IBPlatformToolLaunchContext : NSObject

@property(readonly, nonatomic) NSString *toolName;

@end

@protocol IBAbstractPlatformToolExecutionContext <NSObject>

@optional

- (BOOL)populateEnvironment:(id)arg1 launchContext:(id)arg2 error:(id *)arg3;

@end

@interface IBAbstractPlatformToolExecutionContext : NSObject <IBAbstractPlatformToolExecutionContext>
@end

@protocol IBAbstractWorkspaceDocumentClassProvider <NSObject>

@optional

@property(readonly) IDEWorkspace *workspace;

@end

@interface IBAbstractWorkspaceDocumentClassProvider : NSObject <IBAbstractWorkspaceDocumentClassProvider>
@end

@protocol IBSourceCodeClassProvider <IBAbstractWorkspaceDocumentClassProvider>

@optional

- (void)_notifyObserversOfAffectedFilePaths:(id)arg1 andAffectedClassNames:(id)arg2;

@end

@interface IBSourceCodeClassProvider : IBAbstractWorkspaceDocumentClassProvider <IBSourceCodeClassProvider>
@end
