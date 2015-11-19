//
//  DVTKit.h
//  Crayons
//
//  Created by Fabio Ritrovato on 17/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

@interface DVTAbstractColorPicker : NSView

- (void)takeDrawnColorFromPopUpMenu:(id)arg1;
- (void)populateColorsMenu;
- (id)swatchImageForColor:(id)arg1 withSize:(struct CGSize)arg2;

@end

@interface DVTColorPickerPopUpButton : DVTAbstractColorPicker
@end
