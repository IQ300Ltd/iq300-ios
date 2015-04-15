//
//  ManagedTodoListModel.h
//  IQ300
//
//  Created by Tayphoon on 07.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface ManagedTodoListModel : NSObject<IQTableModel>

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, readonly) NSArray * items;
@property (nonatomic, assign) CGFloat cellWidth;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (BOOL)isItemCheckedAtIndexPath:(NSIndexPath*)indexPath;

- (BOOL)isItemSelectableAtIndexPath:(NSIndexPath*)indexPath;

- (void)completeTodoItemAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;

- (void)rollbackTodoItemWithId:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

@end
