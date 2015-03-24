//
//  CheckListItemCell.m
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TodoListItemCell.h"
#import "IQTodoItem.h"

#define TEXT_COLOR [UIColor colorWithHexInt:0x272727]
#define SELECTED_TEXT_COLOR [UIColor colorWithHexInt:0x9f9f9f]

@implementation TodoListItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        
        _contentInsets = UIEdgeInsetsHorizontalMake(13.0f);
        _accessoryImageView = [[UIImageView alloc] init];
        self.accessoryView = _accessoryImageView;
        
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;

        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:13]];
        [_titleLabel setTextColor:TEXT_COLOR];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.text = NSLocalizedString(@"Checklist", nil);
        _titleLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:_titleLabel];

    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGSize accessorySize = [_accessoryImageView image].size;
    self.accessoryView.frame = CGRectMake(actualBounds.origin.x,
                                          actualBounds.origin.y + (actualBounds.size.height - accessorySize.height) / 2.0f,
                                          accessorySize.width,
                                          accessorySize.height);
    
    _titleLabel.frame = CGRectMake(CGRectRight(self.accessoryView.frame) + 10.0f,
                                   actualBounds.origin.y,
                                   actualBounds.size.width - self.accessoryView.frame.origin.x,
                                   actualBounds.size.height);
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    
    if (accessoryType == UITableViewCellAccessoryCheckmark) {
        _accessoryImageView.image = [UIImage imageNamed:@"gray_checked_checkbox.png"];
        _titleLabel.textColor = SELECTED_TEXT_COLOR;
    } else {
        _accessoryImageView.image = [UIImage imageNamed:@"gray_checkbox.png"];
        _titleLabel.textColor = TEXT_COLOR;
    }
}

- (void)setItem:(IQTodoItem*)item {
    _item = item;
    self.titleLabel.text = _item.title;
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle {
    
}

@end
