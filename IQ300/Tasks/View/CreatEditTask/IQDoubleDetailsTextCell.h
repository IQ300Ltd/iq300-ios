//
//  IQDoubleDetailsTextCell.h
//  IQ300
//
//  Created by Tayphoon on 19.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "PlaceholderTextView.h"

@interface IQDoubleDetailsTextCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
    UIImageView * _accessoryImageView;
    UIImageView * _secondAccessoryImageView;
}

@property (nonatomic, strong) NSArray * item;
@property (nonatomic, strong) NSString * detailTitle;
@property (nonatomic, strong) NSString * secondDetailTitle;
@property (nonatomic, readonly) PlaceholderTextView * titleTextView;
@property (nonatomic, readonly) PlaceholderTextView * secondTitleTextView;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, getter = isSecondEnabled) BOOL secondEnabled;

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end
