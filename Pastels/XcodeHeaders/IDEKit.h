//
//  IDEKit.h
//  Pastels
//
//  Created by Fabio Ritrovato on 06/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

@class IDEWorkspace;

@interface IDEViewController : NSViewController

@property(readonly) IDEWorkspace *workspace;

@end

@interface IDEInspectorViewController : IDEViewController
@end
