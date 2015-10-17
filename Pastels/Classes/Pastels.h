//
//  Pastels.h
//  Pastels
//
//  Created by Fabio Ritrovato on 17/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import <AppKit/AppKit.h>

@class Pastels;

static Pastels *sharedPlugin;

@interface Pastels : NSObject

@property (nonatomic, strong, readonly) NSBundle* bundle;

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@end