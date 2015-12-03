//
//  GooglePalette.h
//  CrayonsExample
//
//  Created by Fabio Ritrovato on 03/12/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import <UIKit/UIKit.h>

// From https://www.google.com/design/spec/style/color.html#color-color-palette

@interface GooglePalette : NSObject

UIColor *colorFromRGB(NSInteger rgbValue);

@end
