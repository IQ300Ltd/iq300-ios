//
//  ContactsSectionView.m
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "ContactsSectionView.h"

#define TITLE_OFFSET 10.0f
#define CONTENT_INSETS 13.0f
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA_BOLD size:16]

#define SECTION_MIN_HEIGHT 50.0f
#define SECTION_MAX_HEIGHT 71.5f

@implementation ContactsSectionView

+ (CGFloat)heightForTitle:(NSString*)title width:(CGFloat)cellWidth {
    CGFloat height = CONTENT_INSETS * 2.0f;
    
    if([title length] > 0) {
        CGFloat titleWidth = cellWidth - CONTENT_INSETS * 2.0f;
        CGSize titleSize = [title sizeWithFont:TITLE_FONT
                             constrainedToSize:CGSizeMake(titleWidth, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        height += titleSize.height;
    }
    
    return MIN(MAX(height, SECTION_MIN_HEIGHT), SECTION_MAX_HEIGHT);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _contentInsets = UIEdgeInsetsMakeWithInset(13.0f);
        self.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        self.bottomLineColor = self.backgroundColor;
        self.bottomLineHeight = 0.5f;
        
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor colorWithHexInt:0x4288a7];
        _leftView.userInteractionEnabled = NO;
        [self addSubview:_leftView];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:TITLE_FONT];
        [_titleLabel setTextColor:[UIColor colorWithHexInt:0x272727]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    CGRect mainRect = UIEdgeInsetsInsetRect(actualBounds, _contentInsets);
    
    _leftView.frame = CGRectMake(actualBounds.origin.x,
                                 actualBounds.origin.y,
                                 5.0f,
                                 actualBounds.size.height);
    
    CGFloat titleWidth = mainRect.size.width;
    _titleLabel.frame = CGRectMake(mainRect.origin.x,
                                   mainRect.origin.y,
                                   titleWidth,
                                   mainRect.size.height);
}

- (void)setTitle:(NSString *)title {
    [_titleLabel setText:title];
}

- (NSString*)title {
    return _titleLabel.text;
}

@end
