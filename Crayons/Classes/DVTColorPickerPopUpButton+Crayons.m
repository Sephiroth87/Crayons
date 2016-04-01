//
//  DVTColorPickerPopUpButton+Crayons.m
//  Crayons
//
//  Created by Fabio Ritrovato on 19/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "DVTColorPickerPopUpButton+Crayons.h"
#import "IBBinaryArchiver+Crayons.h"
#import "IDEWorkspace+Crayons.h"
#import "IDEKit.h"
#import "IDEInterfaceBuilderKit.h"
#import "IDEFoundation.h"
#import "DVTFoundation.h"
#import "IBFoundation.h"
#import "IDEInterfaceBuilderCocoaTouchIntegration.h"
#import "IDEInterfaceBuilderKit.h"

@implementation DVTColorPickerPopUpButton (Crayons)

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
    NSMutableDictionary *colorsToUpdate = [NSMutableDictionary new];
    NSMutableSet *namesToUpdate = [NSMutableSet new];
    for (CrayonsPalette *palette in palettes) {
        NSMutableArray *colors = colorsToUpdate[palette.objcClassName] ?: [NSMutableArray new];
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
        id platformDescription = [[NSClassFromString(@"IBCocoaTouchPlatformToolDescription") alloc] initWithTargetRuntime:runtime role:1 scaleFactor:self.window.backingScaleFactor];
        id failedLoadResult;
        IBCocoaTouchToolProxy *tool = [manager cachedRequestProxyAttachingIfNeededWithDescription:platformDescription returningFailedLoadResult:&failedLoadResult];
        if (!tool || failedLoadResult) {
            DLog(@"🖍 Couldn't retrieve tool, %@", failedLoadResult);
            NSMenu *colorsMenu = [self valueForKey: @"_colorsMenu"];
            [colorsMenu addItem:[NSMenuItem separatorItem]];
            NSMenuItem *item = [colorsMenu addItemWithTitle:@"🖍 The IBDesignable tool crashed, but it's not Crayons' fault" action:nil keyEquivalent:@""];
            NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"Crash"];
            NSMenuItem *subItem = [subMenu addItemWithTitle:@"Click for more info" action:@selector(toolCrashedMoreInfoAction) keyEquivalent:@""];
            [subItem setTarget:self];
            item.submenu = subMenu;
            return;
        }
        if (namesToUpdate.count) {
            DLog(@"🖍 updating missing palette names: %@", namesToUpdate);
            NSDictionary *updatedPaletteNames = [tool sendMessage:NSSelectorFromString(@"paletteNamesForClassNames:") toChannelDuring:^BOOL(SEL arg1, id arg2, id *arg3) {
                IBMessageSendChannel *channel = arg2;
                [channel sendMessage:arg1 returnValue:arg3 context:@{CrayonsIBMessageSendChannelCustomParametersKey: namesToUpdate} error:nil arguments:0];
                return YES;
            }];
            DLog(@"🖍 got names: %@", updatedPaletteNames);
            for (CrayonsPalette *palette in palettes) {
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
                [channel sendMessage:arg1 returnValue:arg3 context:@{CrayonsIBMessageSendChannelCustomParametersKey: colorsToUpdate} error:nil arguments:0];
                return YES;
            }];
            DLog(@"🖍 got colors: %@", updatedColors);
            for (CrayonsPalette *palette in palettes) {
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
    // This is temporary until automatic storyboard updates are implemented, as a view has to track a precise palette from the chosen module, and not a random one
    // that's equivalent to it. Also, since objc classes collision resolve in a random one being chose by the IBDesignables tool, that also will need some thikning
    NSMutableOrderedSet *uniquePalettes = [NSMutableOrderedSet orderedSetWithArray:palettes];
    NSCountedSet *uniquePaletteNames = [NSCountedSet setWithArray:[[uniquePalettes array] valueForKeyPath:@"@unionOfObjects.fullName"]];
    if ([uniquePalettes count]) {
        NSMenu *colorsMenu = [self valueForKey: @"_colorsMenu"];
        [colorsMenu addItem:[NSMenuItem separatorItem]];
        NSArray *sortedPalettes = [uniquePalettes sortedArrayUsingComparator:^NSComparisonResult(CrayonsPalette * _Nonnull obj1, CrayonsPalette * _Nonnull obj2) {
            return [obj1.name compare:obj2.name];
        }];
        for (CrayonsPalette *palette in sortedPalettes) {
            if (palette.name && palette.colors.count) {
                NSString *title = [uniquePaletteNames countForObject:[palette fullName]] > 1 && palette.moduleName ? [[palette fullName] stringByAppendingFormat:@" (%@)", palette.moduleName] : [palette fullName];
                NSMenuItem *item = [colorsMenu addItemWithTitle:title action:nil keyEquivalent:@""];
                NSMenu *paletteColorsMenu = [[NSMenu alloc] initWithTitle:title];
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

- (void)toolCrashedMoreInfoAction
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Sephiroth87/Crayons/issues/6#issuecomment-203904784"]];
}

#pragma mark - Helpers

- (IBInspectorViewController *)inspectorViewController
{
    NSView *view = self.superview;
    IBInspectorViewController *inspector = nil;
    while (view != nil) {
        NSViewController *vc = nil;
        if ([view respondsToSelector:NSSelectorFromString(@"dvt_viewController")]) {
            vc = [view valueForKey:@"dvt_viewController"];
        } else if ([view respondsToSelector:NSSelectorFromString(@"viewController")]) {
            vc = [view valueForKey:@"viewController"];
        }
        if ([vc isKindOfClass:NSClassFromString(@"IBInspectorViewController")]) {
            inspector = (IBInspectorViewController *)vc;
            break;
        }
        view = view.superview;
    }
    return inspector;
}

@end
