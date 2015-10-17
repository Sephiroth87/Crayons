//
//  DVTColorPickerPopUpButton+Pastels.m
//  Pastels
//
//  Created by Fabio Ritrovato on 19/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "DVTColorPickerPopUpButton+Pastels.h"
#import "IBBinaryArchiver+Pastels.h"
#import "IDEKit.h"
#import "IDEInterfaceBuilderKit.h"
#import "IDEFoundation.h"
#import "DVTFoundation.h"
#import "IBFoundation.h"
#import "IDEInterfaceBuilderCocoaTouchIntegration.h"
#import "IDEInterfaceBuilderKit.h"

@implementation DVTColorPickerPopUpButton (Pastel)

+ (void)load
{
    [self jr_swizzleMethod:@selector(populateColorsMenu) withMethod:@selector(p_populateColorsMenu) error:NULL];
}

- (void)p_populateColorsMenu
{
    [self p_populateColorsMenu];
    IBInspectorViewController *inspector = [self inspectorViewController];
    IDEWorkspace *workspace = inspector.workspace;
    NSMutableDictionary *colorNamesForClasses = [NSMutableDictionary new];
    for (IDEIndexCallableSymbol *paletteNameMethod in [workspace.index allSymbolsMatchingNames:@[@"paletteName", @"paletteName()"] kind:[DVTSourceCodeSymbolKind classMethodSymbolKind]]) {
        //TODO: Check for methods returning strings
        IDEIndexClassSymbol *class = [paletteNameMethod containerSymbol];
        NSMutableArray *colorNames = [NSMutableArray new];
        for (IDEIndexCallableSymbol *method in [class classMethods]) {
            //TODO: Any better way to check for swift return types?
            if (([[[method returnType] name] isEqualToString:@"UIColor"] || [[method resolution] hasSuffix:@"UIColor"]) && [method numArguments] == 0) {
                [colorNames addObject:[method name]];
            }
        }
        if (colorNames.count) {
            colorNamesForClasses[[class name]] = colorNames;
        }
    }
    IBStoryboardDocument *document = (IBStoryboardDocument *)inspector.inspectedDocument;
    IBCocoaTouchTargetRuntime *runtime = [document cocoaTouchTargetRuntime];
    IBLiveViewsManager *manager = [document liveViewsManager];
    IBCocoaTouchPlatformToolDescription *platformDescription = [[IBCocoaTouchPlatformToolDescription alloc] initWithTargetRuntime:runtime role:1 scaleFactor:self.window.backingScaleFactor];
    IBCocoaTouchToolProxy *tool = [manager cachedRequestProxyAttachingIfNeededWithDescription:platformDescription returningFailedLoadResult:nil];

    // Xcode 6.4
//    IBMessageChannelCocoaTouchToolProxy *tool = [manager cachedRequestProxyAttachingIfNeededForTargetRuntime:runtime scaleFactor:@(self.window.backingScaleFactor) backgroundOperationIdentifier:nil queue:nil returningFailedLoadResult:NULL];
//    IBMessageSendChannel *channel = [tool channel];
//    NSDictionary *palettes = nil;
//    [channel sendMessage:NSSelectorFromString(@"yeah") returnValue:&palettes context:nil error:nil arguments:0];
    
    NSDictionary *palettes = [tool sendMessage:NSSelectorFromString(@"palettesForClassesAndColorNames:") toChannelDuring:^BOOL(SEL arg1, id arg2, id *arg3) {
        IBMessageSendChannel *channel = arg2;
        [channel sendMessage:arg1 returnValue:arg3 context:@{PastelsIBMessageSendChannelCustomParametersKey: colorNamesForClasses} error:nil arguments:0];
        return YES;
    }];
    
    NSLog(@"returned %@", palettes);
    
    if ([palettes count]) {
        NSMenu *colorsMenu = [self valueForKey: @"_colorsMenu"];
        [colorsMenu addItem:[NSMenuItem separatorItem]];
        for (NSString *paletteName in [palettes.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
            NSMenuItem *item = [colorsMenu addItemWithTitle:paletteName action:nil keyEquivalent:@""];
            NSMenu *paletteColorsMenu = [[NSMenu alloc] initWithTitle:paletteName];
            NSDictionary *palette = palettes[paletteName];
            for (NSString *colorName in [palette.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
                NSDictionary *colorDictionary = palette[colorName];
                NSColor *color = nil;
                if (colorDictionary[@"R"] && colorDictionary[@"G"] && colorDictionary[@"B"] && colorDictionary[@"A"]) {
                    color = [NSColor colorWithCalibratedRed:[colorDictionary[@"R"] floatValue] green:[colorDictionary[@"G"] floatValue] blue:[colorDictionary[@"B"] floatValue] alpha:[colorDictionary[@"A"] floatValue]];
                } else if (colorDictionary[@"W"] && colorDictionary[@"A"]) {
                    color = [NSColor colorWithCalibratedWhite:[colorDictionary[@"W"] floatValue] alpha:[colorDictionary[@"A"] floatValue]];
                }
                if (color) {
                    NSMenuItem *subItem = [paletteColorsMenu addItemWithTitle:IBIdentifierToEnglishName(colorName) action:@selector(takeDrawnColorFromPopUpMenu:) keyEquivalent:@""];
                    subItem.representedObject = color;
                    subItem.image = [self swatchImageForColor:color withSize:CGSizeMake(30.0f, 8.0f)];
                    [subItem setTarget:self];
                }
            }
            item.submenu = paletteColorsMenu;
        }
    }
    
}

#pragma mark - Helpers

- (IBInspectorViewController *)inspectorViewController
{
    NSView *view = self.superview;
    IBInspectorViewController *inspector = nil;
    while (view != nil) {
        if ([view respondsToSelector:@selector(viewController)]) {
            NSViewController *vc = [view valueForKey:@"viewController"];
            if ([vc isKindOfClass:[IBInspectorViewController class]]) {
                inspector = (IBInspectorViewController *)vc;
                break;
            }
        }
        view = view.superview;
    }
    return inspector;
}

@end
