//
//  THistoryItemCell.h
//  IQ300
//
//  Created by Tayphoon on 01.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HISTORY_CELL_MAX_HEIGHT 300.0f

@class IQTaskHistoryItem;

@interface THistoryItemCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic, strong) UILabel * userNameLabel;
@property (nonatomic, strong) UILabel * actionLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;

@property (nonatomic, strong) IQTaskHistoryItem * item;

+ (CGFloat)heightForItem:(IQTaskHistoryItem*)item andCellWidth:(CGFloat)cellWidth;

@end
