//
//  CTaskFilterCell.m
//  IQ300
//
//  Created by Tayphoon on 12.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "CTaskFilterCell.h"

@implementation CTaskFilterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        _countLabel = [[UILabel alloc] init];
        [_countLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:13]];
        [_countLabel setTextColor:TEXT_COLOR];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.numberOfLines = 1;
        _countLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_countLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat countLabelWidth = 35.0f;
    CGRect actualBounds = self.contentView.bounds;
    CGRect mainRect = UIEdgeInsetsInsetRect(actualBounds, _contentInsets);
    
    CGSize constrainedSize = CGSizeMake(self.accessoryView.frame.origin.x - countLabelWidth,
                                        mainRect.size.height);

    CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                      constrainedToSize:constrainedSize
                                          lineBreakMode:self.titleLabel.lineBreakMode];

    self.titleLabel.frame = CGRectMake(mainRect.origin.x,
                                       mainRect.origin.y,
                                       titleSize.width,
                                       mainRect.size.height);
    
    self.countLabel.frame = CGRectMake(CGRectRight(self.titleLabel.frame),
                                       mainRect.origin.y,
                                       countLabelWidth,
                                       mainRect.size.height);
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    
    if (accessoryType == UITableViewCellAccessoryCheckmark) {
        self.countLabel.textColor = SELECTED_TEXT_COLOR;
    } else {
        self.countLabel.textColor = TEXT_COLOR;
    }
}

- (void)setItem:(id<TaskFilterItem>)item {
    self.titleLabel.text = item.title;
    self.countLabel.text = [NSString stringWithFormat:@" - %@", ([item.count integerValue] > 99) ? @"99+" : item.count];
}

@end
