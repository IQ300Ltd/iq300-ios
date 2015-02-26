//
//  TaskFilterCell.h
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskFilterCell : UITableViewCell {
    UIView * _cellContentView;
    UIEdgeInsets _contentInsets;
    UIImageView * _accessoryImageView;
}

@property (nonatomic, readonly) UILabel * titleLabel;

@property (nonatomic, assign, setter = setBottomLineShown:) BOOL isBottomLineShown;

@end
