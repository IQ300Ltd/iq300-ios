//
//  IQDetailsTextCell.m
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQDetailsTextCell.h"

#define ACCESSORY_VIEW_SIZE 17.0f
#define TITLE_OFFSET 10.0f

@implementation IQDetailsTextCell

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * text = ([item isKindOfClass:[NSString class]]) ? item : detailTitle;
    CGFloat cellWidth = width - CONTENT_HORIZONTAL_INSETS * 2.0f;
    CGFloat textWidth = cellWidth - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
    CGFloat height = CONTENT_VERTICAL_INSETS * 2.0f;
    
    UITextView * titleTextView = [[UITextView alloc] init];
    [titleTextView setFont:TEXT_FONT];
    titleTextView.textAlignment = NSTextAlignmentLeft;
    titleTextView.backgroundColor = [UIColor clearColor];
    titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    titleTextView.textContainerInset = UIEdgeInsetsZero;
    titleTextView.contentInset = UIEdgeInsetsZero;
    titleTextView.scrollEnabled = NO;
    titleTextView.text = text;
    [titleTextView sizeToFit];
    
    CGFloat titleHeight = [titleTextView sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height;
    height += titleHeight;
    
    return MIN(MAX(height, CELL_MIN_HEIGHT), CELL_MAX_HEIGHT);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.titleTextView.userInteractionEnabled = NO;
        self.titleTextView.editable = NO;
        self.titleTextView.textContainer.maximumNumberOfLines = 3;
        self.titleTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;

        
        _accessoryImageView = [[UIImageView alloc] init];
        _accessoryImageView.contentMode = UIViewContentModeCenter;
        _accessoryImageView.image = [UIImage imageNamed:@"right_gray_arrow.png"];
        [self.contentView addSubview:_accessoryImageView];
    }
    
    return self;
}

- (void)setAccessoryImage:(UIImage *)accessoryImage {
    _accessoryImageView.image = accessoryImage;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    _accessoryImageView.image = (enabled) ? [UIImage imageNamed:@"right_gray_arrow.png"] : nil;
}

- (UIImage*)accessoryImage {
    return _accessoryImageView.image;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGSize accessorySize = CGSizeMake(ACCESSORY_VIEW_SIZE, ACCESSORY_VIEW_SIZE);
    _accessoryImageView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - accessorySize.width,
                                           actualBounds.origin.y + (actualBounds.size.height - accessorySize.height) / 2.0f,
                                           accessorySize.width,
                                           accessorySize.height);
    
    
    CGFloat titleWidth = actualBounds.size.width - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
    CGFloat titleHeight = [self.titleTextView sizeThatFits:CGSizeMake(titleWidth, CGFLOAT_MAX)].height;
    
    self.titleTextView.frame = CGRectMake(actualBounds.origin.x,
                                          actualBounds.origin.y + (actualBounds.size.height - titleHeight) / 2.0f,
                                          titleWidth,
                                          titleHeight);
}

@end
