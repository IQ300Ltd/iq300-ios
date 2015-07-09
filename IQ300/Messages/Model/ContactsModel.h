//
//  ContactsModel.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface ContactsModel : NSObject<IQTableModel>

@property (nonatomic, readonly) NSArray * users;
@property (nonatomic, readonly) NSUInteger portionOffset;
@property (nonatomic, readonly) NSUInteger portionSize;

@property (nonatomic, strong) NSString * sectionNameKeyPath;
@property (nonatomic, strong) NSString * filter;
@property (nonatomic, strong) NSArray * excludeUserIds;
@property (nonatomic, strong) NSPredicate * predicate;
@property (nonatomic, strong) NSArray  * sortDescriptors;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

+ (instancetype)modelWithPortionSize:(NSUInteger)portionSize;

- (id)initWithPortionSize:(NSUInteger)portionSize;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion;

- (void)reloadModelSourceControllerWithCompletion:(void (^)(NSError * error))completion;

@end
