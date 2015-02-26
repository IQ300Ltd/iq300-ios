//
//  TaskFilterCell.m
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskFilterCell.h"
#import "BottomLineView.h"
#import "TaskFilterConst.h"

#define CONTENT_LEFT_INSET 12
#define CONTENT_LEFT_RIGHT 10

@interface TaskFilterCell() {
    
}

@end

@implementation TaskFilterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        _accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.accessoryView = _accessoryImageView;
        
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;

        _contentInsets = UIEdgeInsetsMake(0, CONTENT_LEFT_INSET, 0, CONTENT_LEFT_RIGHT);
        _isBottomLineShown = YES;
        
        _cellContentView = [[BottomLineView alloc] init];
        [_cellContentView setBackgroundColor:[UIColor clearColor]];
        [((BottomLineView*)_cellContentView) setBottomLineColor:SEPARATOR_COLOR];
        [((BottomLineView*)_cellContentView) setBottomLineHeight:1.0f];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:13]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_cellContentView addSubview:_titleLabel];
        
        [self.contentView addSubview:_cellContentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _cellContentView.frame = self.bounds;
    
    self.accessoryView.frame = CGRectMake(self.bounds.size.width - self.accessoryView.frame.size.width - 4.5,
                                          self.accessoryView.frame.origin.y,
                                          self.accessoryView.frame.size.width,
                                          self.accessoryView.frame.size.height);
    
    CGRect actualBounds = _cellContentView.bounds;
    CGRect mainRect = UIEdgeInsetsInsetRect(actualBounds, _contentInsets);
    
    _titleLabel.frame = CGRectMake(mainRect.origin.x,
                                   mainRect.origin.y,
                                   self.accessoryView.frame.origin.x,
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

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    
    if (accessoryType == UITableViewCellAccessoryCheckmark) {
        _accessoryImageView.image = [UIImage imageNamed:@"filterSelected.png"];
        self.textLabel.textColor = [UIColor colorWithHexInt:0x0683d8];
    } else {
        _accessoryImageView.image = nil;
        [self.textLabel setTextColor:[UIColor colorWithHexInt:0x575656]];
    }
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle {
    
}

@end
