//
//  TaskExecutorsModel.h
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel+Subclass.h"

@interface TaskExecutorsModel : IQTableModel

@property (nonatomic, strong) NSString * filter;
@property (nonatomic, strong) NSNumber * communityId;
@property (nonatomic, strong) NSArray * executors;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign, getter=isAllSelected) BOOL selectAll;
@property (nonatomic, assign, getter=isEditingMode) BOOL editingMode;

- (BOOL)isSectionSelected:(NSInteger)section;
- (void)makeSection:(NSInteger)section selected:(BOOL)selected;

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

@end
