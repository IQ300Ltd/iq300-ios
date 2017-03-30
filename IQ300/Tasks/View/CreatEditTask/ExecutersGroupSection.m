//
//  ExecutersGroupSection.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "ExecutersGroupSection.h"

#define ACCESSORY_VIEW_WIDHT  15.0f
#define ACCESSORY_VIEW_HEIGHT 12.0f
#define TITLE_OFFSET 10.0f
#define CONTENT_INSETS 13.0f
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA_BOLD size:16]

#define SECTION_MIN_HEIGHT 50.0f
#define SECTION_MAX_HEIGHT 71.5f

@interface ExecutersGroupSection() {
    UITapGestureRecognizer * _singleTapGesture;
}

@end

@implementation ExecutersGroupSection

+ (CGFloat)heightForTitle:(NSString*)title width:(CGFloat)cellWidth {
    CGFloat height = CONTENT_INSETS * 2.0f;
    
    if([title length] > 0) {
        CGFloat titleWidth = cellWidth - ACCESSORY_VIEW_WIDHT - TITLE_OFFSET - CONTENT_INSETS * 2.0f;
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
        self.backgroundColor = IQ_GRAY_LIGHT_COLOR;
        self.bottomLineColor = self.backgroundColor;
        self.bottomLineHeight = 0.5f;
        
        _showLeftView = YES;
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = IQ_BACKGROUND_P4_COLOR;
        _leftView.userInteractionEnabled = NO;
        [self addSubview:_leftView];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:TITLE_FONT];
        [_titleLabel setTextColor:IQ_FONT_BLACK_COLOR];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];
        
        _accessoryImageView = [[UIImageView alloc] init];
        _accessoryImageView.userInteractionEnabled = NO;
        [self addSubview:_accessoryImageView];
        
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        _singleTapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_singleTapGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    CGRect mainRect = UIEdgeInsetsInsetRect(actualBounds, _contentInsets);
    
    if (self.isLeftViewShown) {
        _leftView.frame = CGRectMake(actualBounds.origin.x,
                                     actualBounds.origin.y,
                                     5.0f,
                                     actualBounds.size.height);
    }
    
    CGSize accessorySize = CGSizeMake(ACCESSORY_VIEW_WIDHT, ACCESSORY_VIEW_HEIGHT);
    _accessoryImageView.frame = CGRectMake(mainRect.origin.x + mainRect.size.width - accessorySize.width,
                                           mainRect.origin.y + (mainRect.size.height - accessorySize.height) / 2.0f,
                                           accessorySize.width,
                                           accessorySize.height);

    
    CGFloat titleWidth = mainRect.size.width - ACCESSORY_VIEW_WIDHT - TITLE_OFFSET;
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

- (void)setActionBlock:(void (^)(ExecutersGroupSection*))block {
    _actionBlock = [block copy];
}

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        [self updateUIForState];
    }
}

- (void)setShowLeftView:(BOOL)showLeftView {
    if (_showLeftView != showLeftView) {
        _showLeftView = showLeftView;
        
        _leftView.hidden = !_showLeftView;
    }
}

#pragma mark - Private methods

- (void)singleTapRecognized:(UITapGestureRecognizer*)recognizer {
    if (_actionBlock) {
        _actionBlock(self);
    }
}

- (void)updateUIForState {
    _accessoryImageView.image = (_selected) ? [UIImage imageNamed:@"filterSelected.png"] : nil;
}

@end
