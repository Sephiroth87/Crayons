//
//  DVTFoundation.h
//  Crayons
//
//  Created by Fabio Ritrovato on 07/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

@interface DVTSourceCodeSymbolKind : NSObject

+ (id)classMethodSymbolKind;
+ (id)classSymbolKind;

@property(readonly, copy) NSString *identifier;

@end

@interface DVTUserNotificationCenter : NSObject <NSUserNotificationCenterDelegate>

+ (id)defaultUserNotificationCenter;
- (void)deliverNotification:(id)arg1;

@end

@interface DVTFilePath : NSObject
@end
