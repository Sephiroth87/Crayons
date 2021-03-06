//
//  IDEFoundation.h
//  Crayons
//
//  Created by Fabio Ritrovato on 06/10/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

#import "DVTFoundation.h"

@interface IDEIndex : NSObject

- (id)allSymbolsMatchingNames:(id)arg1 kind:(id)arg2;
- (BOOL)_reopenDatabaseWithRemoval:(BOOL)arg1;

@end

@interface IDEWorkspace : NSObject

@property(retain) IDEIndex *index;

- (void)didCreateIndex:(id)arg1;

@end

@interface IDEIndexCollection : NSObject <NSFastEnumeration>
@end

@interface IDEIndexSymbolOccurrence : NSObject

@property (nonatomic, readonly) DVTFilePath *file;

@end

@interface IDEIndexSymbol : IDEIndexSymbolOccurrence

@property(readonly, nonatomic) NSString *name;
@property(readonly, nonatomic) DVTSourceCodeSymbolKind *symbolKind;
@property(readonly, nonatomic) NSString *resolution;
@property(readonly, nonatomic) IDEIndexCollection *definitions;
@property(readonly, nonatomic, getter=isInProject) BOOL inProject;

- (id)file;
- (id)occurrences;

@end

@interface IDEIndexCallableSymbol : IDEIndexSymbol

- (id)containerSymbol;
- (id)returnType;
- (unsigned long long)numArguments;

@end

@interface IDEIndexContainerSymbol : IDEIndexSymbol

- (id)children;

@end

@interface IDEIndexClassSymbol : IDEIndexContainerSymbol

- (id)categories;

@end

@interface IDEIndexCategorySymbol : IDEIndexContainerSymbol

- (id)relatedClass;

@end
