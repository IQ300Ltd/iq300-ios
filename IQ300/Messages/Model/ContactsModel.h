//
//  ContactsModel.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQSelectionManagedModel.h"

@interface ContactsModel : IQSelectionManagedModel

@property (nonatomic, readonly) NSArray * contacts;
@property (nonatomic, readonly) NSUInteger portionOffset;
@property (nonatomic, readonly) NSUInteger portionSize;

@property (nonatomic, strong) NSString * filter;
@property (nonatomic, strong) NSArray * excludeUserIds;
@property (nonatomic, strong) NSPredicate * predicate;

+ (instancetype)modelWithPortionSize:(NSUInteger)portionSize;

- (id)initWithPortionSize:(NSUInteger)portionSize;

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

@end
