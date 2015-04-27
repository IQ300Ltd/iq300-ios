//
//  TActivityItemCell.h
//  IQ300
//
//  Created by Tayphoon on 01.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ACTIVITY_CELL_MAX_HEIGHT 300.0f

@class IQTaskActivityItem;

@interface TActivityItemCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * userNameLabel;
@property (nonatomic, strong) UILabel * actionLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;

@property (nonatomic, strong) IQTaskActivityItem * item;

+ (CGFloat)heightForItem:(IQTaskActivityItem*)item andCellWidth:(CGFloat)cellWidth;

@end
