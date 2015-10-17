//
//  IBFoundation.h
//  Pastels
//
//  Created by Fabio on 09/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

extern NSString *IBIdentifierToEnglishName(NSString *);

@interface IBMessageSendChannel : NSObject

- (BOOL)sendMessage:(SEL)arg1 returnValue:(id *)arg2 context:(id)arg3 error:(id *)arg4 arguments:(int)arg5;

@end

@interface IBBinaryArchiver : NSObject

- (id)initWithVersion:(long long)arg1 context:(id)arg2;
- (void)encodeObject:(id)arg1;
- (void)encodeInteger:(long long)arg1;

@end
