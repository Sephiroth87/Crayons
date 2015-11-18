//
//  DVTColorPickerPopUpButton+Pastels.m
//  Pastels
//
//  Created by Fabio Ritrovato on 19/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "DVTColorPickerPopUpButton+Pastels.h"
#import "IBBinaryArchiver+Pastels.h"
#import "IDEWorkspace+Pastels.h"
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
    NSArray *palettes = workspace.palettes;
    [workspace updateColors:palettes];
    NSMutableDictionary *colorsToUpdate = [NSMutableDictionary new];
    NSMutableArray *namesToUpdate = [NSMutableArray new];
    for (PastelsPalette *palette in palettes) {
        NSMutableArray *colors = [NSMutableArray new];
        [palette.colors enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj == [NSNull null]) {
                [colors addObject:key];
            }
        }];
        if (colors.count) {
            [colorsToUpdate setObject:colors forKey:palette.objcClassName];
        }
        if (!palette.name) {
            [namesToUpdate addObject:palette.objcClassName];
        }
    }
    if (colorsToUpdate.count || namesToUpdate.count) {
        IBStoryboardDocument *document = (IBStoryboardDocument *)inspector.inspectedDocument;
        IBCocoaTouchTargetRuntime *runtime = [document cocoaTouchTargetRuntime];
        IBLiveViewsManager *manager = [document liveViewsManager];
        IBCocoaTouchPlatformToolDescription *platformDescription = [[IBCocoaTouchPlatformToolDescription alloc] initWithTargetRuntime:runtime role:1 scaleFactor:self.window.backingScaleFactor];
        IBCocoaTouchToolProxy *tool = [manager cachedRequestProxyAttachingIfNeededWithDescription:platformDescription returningFailedLoadResult:nil];
        if (namesToUpdate.count) {
            DLog(@"🖍 updating missing palette names: %@", namesToUpdate);
            NSDictionary *updatedPaletteNames = [tool sendMessage:NSSelectorFromString(@"paletteNamesForClassNames:") toChannelDuring:^BOOL(SEL arg1, id arg2, id *arg3) {
                IBMessageSendChannel *channel = arg2;
                [channel sendMessage:arg1 returnValue:arg3 context:@{PastelsIBMessageSendChannelCustomParametersKey: namesToUpdate} error:nil arguments:0];
                return YES;
            }];
            for (PastelsPalette *palette in palettes) {
                NSString *updatedPaletteNameForClass = updatedPaletteNames[palette.objcClassName];
                if (updatedPaletteNameForClass) {
                    palette.name = updatedPaletteNameForClass;
                }
            }
        }
        if (colorsToUpdate.count) {
            DLog(@"🖍 updating missing colors: %@", colorsToUpdate);
            NSDictionary *updatedColors = [tool sendMessage:NSSelectorFromString(@"colorsForClassesAndColorNames:") toChannelDuring:^BOOL(SEL arg1, id arg2, id *arg3) {
                IBMessageSendChannel *channel = arg2;
                [channel sendMessage:arg1 returnValue:arg3 context:@{PastelsIBMessageSendChannelCustomParametersKey: colorsToUpdate} error:nil arguments:0];
                return YES;
            }];
            for (PastelsPalette *palette in palettes) {
                NSDictionary *updatedColorsForClass = updatedColors[palette.objcClassName];
                if (updatedColorsForClass.count) {
                    [palette.colors enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        NSDictionary *colorDictionary = updatedColorsForClass[key];
                        if (colorDictionary) {
                            NSColor *color = nil;
                            if (colorDictionary[@"R"] && colorDictionary[@"G"] && colorDictionary[@"B"] && colorDictionary[@"A"]) {
                                color = [NSColor colorWithCalibratedRed:[colorDictionary[@"R"] floatValue] green:[colorDictionary[@"G"] floatValue] blue:[colorDictionary[@"B"] floatValue] alpha:[colorDictionary[@"A"] floatValue]];
                            } else if (colorDictionary[@"W"] && colorDictionary[@"A"]) {
                                color = [NSColor colorWithCalibratedWhite:[colorDictionary[@"W"] floatValue] alpha:[colorDictionary[@"A"] floatValue]];
                            }
                            palette.colors[key] = color;
                        }
                    }];
                }
            }
        }
    }
    if ([palettes count]) {
        NSMenu *colorsMenu = [self valueForKey: @"_colorsMenu"];
        [colorsMenu addItem:[NSMenuItem separatorItem]];
        NSArray *sortedPalettes = [palettes sortedArrayUsingComparator:^NSComparisonResult(PastelsPalette * _Nonnull obj1, PastelsPalette * _Nonnull obj2) {
            return [obj1.name compare:obj2.name];
        }];
        for (PastelsPalette *palette in sortedPalettes) {
            if (palette.name) {
                NSMenuItem *item = [colorsMenu addItemWithTitle:palette.name action:nil keyEquivalent:@""];
                NSMenu *paletteColorsMenu = [[NSMenu alloc] initWithTitle:palette.name];
                for (NSString *colorName in [palette.colors.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
                    id color = palette.colors[colorName];
                    if (color && color != [NSNull null]) {
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
