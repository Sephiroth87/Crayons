//
//  DVTFoundation.h
//  Pastels
//
//  Created by Fabio Ritrovato on 07/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

@interface DVTSourceCodeSymbolKind : NSObject

+ (id)classMethodSymbolKind;

@end

@interface NSString (DVTFoundationClassAdditions)

- (id)dvt_capitalizedWordsFromString;

@end

@interface DVTTask : NSObject

@property(copy) NSString *launchPath;

- (void)setValue:(id)arg1 forEnvironmentVariableNamed:(id)arg2;

@end