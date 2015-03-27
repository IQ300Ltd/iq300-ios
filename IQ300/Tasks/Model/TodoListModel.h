//
//  TodoListModel.h
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface TodoListModel : NSObject<IQTableModel>

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) NSArray * items;
@property (nonatomic, assign) CGFloat cellWidth;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (BOOL)isItemCheckedAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isItemSelectableAtIndexPath:(NSIndexPath*)indexPath;
- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath checked:(BOOL)checked;

@end
