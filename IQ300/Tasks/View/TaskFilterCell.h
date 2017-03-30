//
//  TaskFilterCell.h
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskFilterItem.h"

#define TEXT_COLOR IQ_FONT_BLACK_COLOR
#define SELECTED_TEXT_COLOR IQ_BLUE_COLOR

@interface TaskFilterCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
    UIImageView * _accessoryImageView;
}

@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, strong) id<TaskFilterItem> item;
@property (nonatomic, assign, setter = setBottomLineShown:) BOOL isBottomLineShown;

@end
