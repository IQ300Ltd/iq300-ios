//
//  CheckListItemCell.m
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TodoListItemCell.h"
#import "IQTodoItem.h"

#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define TEXT_COLOR [UIColor colorWithHexInt:0x272727]
#define SELECTED_TEXT_COLOR [UIColor colorWithHexInt:0x9f9f9f]
#define CONTENT_VERTICAL_INSETS 12
#define CONTENT_HORIZONTAL_INSETS 13
#define ACCESSORY_VIEW_SIZE 20.0f
#define TITLE_OFFSET 10.0f

@implementation TodoListItemCell

+ (CGFloat)heightForItem:(IQTodoItem *)item width:(CGFloat)width {
    CGFloat cellWidth = width - CONTENT_VERTICAL_INSETS * 2.0f - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
    CGFloat height = CONTENT_HORIZONTAL_INSETS * 2.0f;
    
    CGSize titleLabelSize = [item.title sizeWithFont:TITLE_FONT
                                   constrainedToSize:CGSizeMake(cellWidth, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    
    height += titleLabelSize.height;
    
    
    return MAX(height, 50.0f);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        
        _enabled = YES;
        _contentInsets = UIEdgeInsetsMake(CONTENT_VERTICAL_INSETS, CONTENT_HORIZONTAL_INSETS, CONTENT_VERTICAL_INSETS, CONTENT_HORIZONTAL_INSETS);
        _accessoryImageView = [[UIImageView alloc] init];
        self.accessoryView = _accessoryImageView;
        
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;

        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:TITLE_FONT];
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
    
    CGSize accessorySize = CGSizeMake(ACCESSORY_VIEW_SIZE, ACCESSORY_VIEW_SIZE);
    self.accessoryView.frame = CGRectMake(actualBounds.origin.x,
                                          actualBounds.origin.y + (actualBounds.size.height - accessorySize.height) / 2.0f,
                                          accessorySize.width,
                                          accessorySize.height);
    
    _titleLabel.frame = CGRectMake(CGRectRight(self.accessoryView.frame) + TITLE_OFFSET,
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
        _titleLabel.textColor = (_enabled) ? TEXT_COLOR : SELECTED_TEXT_COLOR;
    }
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        UIColor * curColor = (self.accessoryType == UITableViewCellAccessoryCheckmark) ? SELECTED_TEXT_COLOR : TEXT_COLOR;
        _titleLabel.textColor = (_enabled) ? curColor : SELECTED_TEXT_COLOR;
    }
}

- (void)setItem:(IQTodoItem*)item {
    _item = item;
    self.titleLabel.text = _item.title;
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle {
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _enabled = YES;
    [_titleLabel setTextColor:TEXT_COLOR];
}

@end
