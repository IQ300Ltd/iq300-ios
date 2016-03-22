//
//  TaskModel.h
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel+Subclass.h"

@class IQTaskDataHolder;
@class IQCommunity;
@class IQTask;

@interface TaskModel : IQTableModel

@property (nonatomic, strong, readonly) IQTaskDataHolder * task;
@property (nonatomic, strong, readonly) IQCommunity * defaultCommunity;

@property (nonatomic, assign) CGFloat cellWidth;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDefaultCommunity:(IQCommunity *)community;
- (instancetype)initWithDefaultCommunity:(IQCommunity *)community parentTask:(IQTask *)task;
- (instancetype)initWithTask:(IQTaskDataHolder *)task;

- (void)updateItem:(id)item atIndexPath:(NSIndexPath *)indexPath withValue:(id)value;

- (NSInteger)maxNumberOfCharactersForPath:(NSIndexPath*)indexPath;

- (BOOL)modelHasChanges;

@end
