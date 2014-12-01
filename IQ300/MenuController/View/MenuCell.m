//
//  MenuCell.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "MenuCell.h"
#import "BottomLineView.h"
#import "MenuConsts.h"
#import "IQBadgeView.h"

#define BACKGROUND_COLOR [UIColor colorWithHexInt:0x1d2124]
#define SELECTED_BBACKGROUND_COLOR [UIColor colorWithHexInt:0x272d31]
#define BADGE_HEIGHT 25
#define CONTENT_LEFT_INSET 12
#define CONTENT_LEFT_RIGHT 10

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
        _contentInsets = UIEdgeInsetsMake(0, CONTENT_LEFT_INSET, 0, CONTENT_LEFT_RIGHT);
        _isBottomLineShown = YES;
        
        _selectedBackgroundView = [[UIView alloc] init];
        [_selectedBackgroundView setBackgroundColor:SELECTED_BBACKGROUND_COLOR];
        [self setSelectedBackgroundView:_selectedBackgroundView];
       
        _cellContentView = [[BottomLineView alloc] init];
        [_cellContentView setBackgroundColor:BACKGROUND_COLOR];
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
        
        _badgeView = [IQBadgeView customBadgeWithString:nil];
        [_cellContentView addSubview:_badgeView];
        
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
    
    _badgeView.frame = CGRectMake(mainRect.origin.x + mainRect.size.width - _badgeView.frame.size.width,
                                  mainRect.origin.y + (mainRect.size.height - _badgeView.frame.size.height) / 2,
                                  _badgeView.frame.size.width,
                                  _badgeView.frame.size.height);
    
    _titleLabel.frame = CGRectMake(mainRect.origin.x,
                                   mainRect.origin.y,
                                   _badgeView.frame.origin.x - mainRect.origin.x,
                                   mainRect.size.height);
}

- (void)setBottomLineShown:(BOOL)isBottomLineShown {
    if(_isBottomLineShown != isBottomLineShown) {
        _isBottomLineShown = isBottomLineShown;
        
        _contentInsets = UIEdgeInsetsMake(0,
                                          CONTENT_LEFT_INSET,
                                          (_isBottomLineShown) ? 1 : 0,
                                          CONTENT_LEFT_RIGHT);
        [self setNeedsLayout];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
   // [_cellContentView setBackgroundColor:(selected) ? SELECTED_BBACKGROUND_COLOR : BACKGROUND_COLOR];
}

- (void)setItem:(IQMenuItem *)item {
    _item = item;
    
    _titleLabel.text = item.title;
}

- (NSString*)badgeText {
    return _badgeView.badgeText;
}

- (void)setBadgeText:(NSString *)badgeText {
    if([badgeText length] > 0) {
        [_badgeView setHidden:NO];
        [_badgeView autoBadgeSizeWithString:badgeText];
    }
    else {
        [_badgeView setHidden:YES];
    }
}

@end
