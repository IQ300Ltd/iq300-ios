//
//  TaskFilterCell.h
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskFilterItem.h"

#define TEXT_COLOR [UIColor colorWithHexInt:0x20272a]
#define SELECTED_TEXT_COLOR [UIColor colorWithHexInt:0x358bae]

@interface TaskFilterCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
    UIImageView * _accessoryImageView;
}

@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, strong) id<TaskFilterItem> item;
@property (nonatomic, assign, setter = setBottomLineShown:) BOOL isBottomLineShown;

@end
