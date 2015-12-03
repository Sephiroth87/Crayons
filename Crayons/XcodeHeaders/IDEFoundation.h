//
//  IDEFoundation.h
//  Crayons
//
//  Created by Fabio Ritrovato on 06/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

@interface IDEIndex : NSObject

- (id)allSymbolsMatchingNames:(id)arg1 kind:(id)arg2;
- (void)doWhenFilesReady:(void (^)(void))arg1;

@end

@interface IDEWorkspace : NSObject

@property(retain) IDEIndex *index;

@end

@interface IDEIndexCollection : NSObject <NSFastEnumeration>
@end

@interface IDEIndexSymbol : NSObject

@property(readonly, nonatomic) NSString *name;
@property(readonly, nonatomic) NSString *resolution;
@property(readonly, nonatomic) IDEIndexCollection *definitions;
@property(readonly, nonatomic, getter=isInProject) BOOL inProject;

- (id)file;

@end

@interface IDEIndexCallableSymbol : IDEIndexSymbol

- (id)containerSymbol;
- (id)returnType;
- (unsigned long long)numArguments;

@end

@interface IDEIndexClassSymbol : IDEIndexSymbol

- (id)classMethods;
- (id)categories;

@end

@interface IDEIndexCategorySymbol : IDEIndexSymbol

- (id)relatedClass;
- (id)classMethods;

@end
