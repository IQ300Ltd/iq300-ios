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

@interface TaskModel : IQTableModel

@property (nonatomic, strong) IQTaskDataHolder * task;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) IQCommunity * defaultCommunity;

- (NSString*)placeholderForItemAtIndexPath:(NSIndexPath*)indexPath;

- (NSString*)detailTitleForItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)updateFieldAtIndexPath:(NSIndexPath*)indexPath withValue:(id)value;

- (BOOL)isItemEditableAtIndexPath:(NSIndexPath*)indexPath;

/**
 *  Real index path
 *
 *  @param indexPath Selected index path
 *
 *  @return Real index path(exclude hidden index paths)
 */
- (NSIndexPath*)realIndexPathForPath:(NSIndexPath*)indexPath;

- (BOOL)modelHasChanges;

@end
