//
//  ContactsModel.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "ContactsModel.h"
#import "IQService+Messages.h"
#import "ContactCell.h"

#define SORT_DIRECTION IQSortDirectionAscending

static NSString * UReuseIdentifier = @"UReuseIdentifier";

@interface ContactsModel() {
    NSMutableArray * _contacts;
}

@end

@implementation ContactsModel

+ (instancetype)modelWithPortionSize:(NSUInteger)portionSize {
    return [[self alloc] initWithPortionSize:portionSize];
}

- (id)initWithPortionSize:(NSUInteger)portionSize {
    self = [super init];
    if(self) {
        _contacts = [NSMutableArray array];
        _portionSize = portionSize;
        self.allowsMultipleSelection = YES;
        self.allowsDeselection = YES;
        self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"user.displayName" ascending:SORT_DIRECTION == IQSortDirectionAscending]];
    }
    return self;
}

- (id)init {
    return [self initWithPortionSize:20];
}

- (NSArray*)contacts {
    return [_contacts copy];
}

- (NSString*)cacheFileName {
    return @"ContactsModelCache";
}

- (NSString*)entityName {
    return @"IQContact";
}

- (NSManagedObjectContext*)context {
    return [IQService sharedService].context;
}

- (Class)cellClass {
    return [ContactCell class];
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    return [[self.cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                                 reuseIdentifier:UReuseIdentifier];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return UReuseIdentifier;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 68;
}

- (NSPredicate*)fetchPredicate {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ownerId == %@", [IQSession defaultSession].userId];

    if([_filter length] > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(user.displayName CONTAINS[cd] %@) OR (user.email CONTAINS[cd] %@)", _filter, _filter];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
    }
    
    if([_excludeUserIds count] > 0) {
        NSPredicate * usersPredicate = [NSPredicate predicateWithFormat:@"NOT (user.userId IN %@)", _excludeUserIds];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, usersPredicate]];
    }
    
    return predicate;
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    id item = [self itemAtIndexPath:indexPath];
    if (selected && ![_contacts containsObject:item]) {
        [_contacts addObject:item];
    }
    else if(!selected && [_contacts containsObject:item]) {
        [_contacts removeObject:item];
    }
}

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    return [_contacts containsObject:item];
}


- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        [[IQService sharedService] contactsWithPage:@(1)
                                                per:@(_portionSize)
                                               sort:SORT_DIRECTION
                                             search:_filter
                                            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                if(completion) {
                                                    completion(error);
                                                }
                                            }];
    }
}

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelWithCompletion:completion];
    }
    else {
        NSInteger count = [self numberOfItemsInSection:0];
        _portionOffset = (count > 0) ? count / _portionSize + 1 : 0;
        [[IQService sharedService] contactsWithPage:@(_portionOffset)
                                                per:@(_portionSize)
                                               sort:SORT_DIRECTION
                                             search:_filter
                                            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                if(completion) {
                                                    completion(error);
                                                }
                                            }];
    }
}

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion {
    [self reloadModelSourceControllerWithCompletion:^(NSError *error) {
        if (!error) {
            [self modelDidChanged];
        }
    }];
    
    [[IQService sharedService] contactsWithPage:@(1)
                                            per:@(_portionSize)
                                           sort:SORT_DIRECTION
                                         search:_filter
                                        handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                            if(completion) {
                                                completion(error);
                                            }
                                        }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
