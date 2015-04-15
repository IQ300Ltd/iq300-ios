//
//  TodoListModel.h
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@protocol TodoItem;

@interface TodoListModel : NSObject<IQTableModel>

@property (nonatomic, readonly) NSArray * items;

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, readonly) BOOL hasChanges;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (id)initWithManagedItems:(NSArray*)items;

- (BOOL)isItemCheckedAtIndexPath:(NSIndexPath*)indexPath;

- (BOOL)isItemSelectableAtIndexPath:(NSIndexPath*)indexPath;

- (void)makeItemAtIndexPath:(NSIndexPath*)indexPath checked:(BOOL)checked;

- (void)createItemWithCompletion:(void (^)(id<TodoItem> item, NSError *error))completion;

- (void)deleteItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)saveChangesWithCompletion:(void (^)(NSError * error))completion;

@end
