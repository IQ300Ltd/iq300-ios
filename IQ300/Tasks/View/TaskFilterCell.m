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
        _accessoryImageView = [[UIImageView alloc] init];
        self.accessoryView = _accessoryImageView;
        
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;

        _contentInsets = UIEdgeInsetsMake(0, CONTENT_LEFT_INSET, 0, CONTENT_LEFT_RIGHT);
        _isBottomLineShown = YES;
                
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:13]];
        [_titleLabel setTextColor:TEXT_COLOR];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize accessorySize = [_accessoryImageView image].size;
    self.accessoryView.frame = CGRectMake(self.bounds.size.width - accessorySize.width - 17,
                                          (self.bounds.size.height - accessorySize.height) / 2.0f - 1.5f,
                                          accessorySize.width,
                                          accessorySize.height);
    
    CGRect actualBounds = self.contentView.bounds;
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
        _titleLabel.textColor = SELECTED_TEXT_COLOR;
    } else {
        _accessoryImageView.image = nil;
        _titleLabel.textColor = TEXT_COLOR;
    }
}

- (void)setItem:(id<TaskFilterItem>)item {
    _item = item;
    self.titleLabel.text = item.title;
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle {
    
}

@end
