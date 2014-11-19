//
//  MenuCell.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <JSBadgeView/JSBadgeView.h>

#import "MenuCell.h"
#import "BottomLineView.h"
#import "MenuConsts.h"

#define BBACKGROUND_COLOR [UIColor colorWithHexInt:0x15191b]
#define SELECTED_BBACKGROUND_COLOR [UIColor colorWithHexInt:0x272d31]
#define BADGE_HEIGHT 25

@interface MenuCell() {
    UIView * _selectedBackgroundView;
    UIEdgeInsets _selectedBackgroundInsets;
}

@end

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        _selectedBackgroundInsets = UIEdgeInsetsMake(0, 0, 1, 0);
        _contentInsets = UIEdgeInsetsMake(0, 44, 0, 10);
        _isBottomLineShown = YES;
        
        _selectedBackgroundView = [[UIView alloc] init];
        [_selectedBackgroundView setBackgroundColor:SELECTED_BBACKGROUND_COLOR];
        [self setSelectedBackgroundView:_selectedBackgroundView];
       
        _cellContentView = [[BottomLineView alloc] init];
        [_cellContentView setBackgroundColor:BBACKGROUND_COLOR];
        [((BottomLineView*)_cellContentView) setBottomLineColor:MENU_CELL_SEPARATOR_COLOR];
        [((BottomLineView*)_cellContentView) setBottomLineHeight:1.0f];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:13]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_titleLabel setText:NSLocalizedString(@"Incoming", nil)];
        [_cellContentView addSubview:_titleLabel];
        
        _badgeView = [[JSBadgeView alloc] initWithParentView:_cellContentView alignment:JSBadgeViewAlignmentCenterRight];
        _badgeView.badgePositionAdjustment = CGPointMake(-20, 0);
        _badgeView.badgeBackgroundColor = [UIColor whiteColor];
        _badgeView.badgeTextColor = [UIColor colorWithHexInt:0x459dbe];
        _badgeView.badgeStrokeColor = [UIColor colorWithHexInt:0x338cae];
        _badgeView.badgeStrokeWidth = 1.0f;
        _badgeView.badgeTextFont = [UIFont fontWithName:@"Helvetica" size:16];
        
        [self.contentView addSubview:_cellContentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _cellContentView.frame = self.bounds;
    _selectedBackgroundView.frame = UIEdgeInsetsInsetRect(self.bounds, _selectedBackgroundInsets);
    
    CGRect actualBounds = _cellContentView.bounds;
    CGRect mainRect = UIEdgeInsetsInsetRect(actualBounds, _contentInsets);
    
    _badgeView.frame = CGRectMake(mainRect.origin.x + mainRect.size.width - mainRect.size.height,
                                  0,
                                  mainRect.size.height,
                                  mainRect.size.height);
    
    _titleLabel.frame = CGRectMake(mainRect.origin.x,
                                   mainRect.origin.y,
                                   _badgeView.frame.origin.x - mainRect.origin.x,
                                   mainRect.size.height);
}

- (void)setBottomLineShown:(BOOL)isBottomLineShown {
    if(_isBottomLineShown != isBottomLineShown) {
        _isBottomLineShown = isBottomLineShown;
        
        _contentInsets = UIEdgeInsetsMake(0,
                                          44,
                                          (_isBottomLineShown) ? 1 : 0,
                                          10);
        [self setNeedsLayout];
    }
}

- (void)setItem:(IQMenuItem *)item {
    _item = item;
    
    _titleLabel.text = item.title;
}

@end
