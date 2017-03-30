//
//  TInfoExpandableLineView.m
//  IQ300
//
//  Created by Tayphoon on 28.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TInfoExpandableLineView.h"

static const CGFloat HEADER_HEIGHT = 45.5f;

@interface TInfoExpandableLineView() {
    void (^_actionBlock)(TInfoExpandableLineView * view);
    UITapGestureRecognizer * _singleTapGesture;
}

@end

@implementation TInfoExpandableLineView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeLeft;
        self.imageView.image = [UIImage imageNamed:@"filter_collapseed.png"];
        self.imageViewSize = CGSizeMake(12.0f, 12.0f);
        
        _enabled = YES;
        
        _detailsTextLabel = [[UITextView alloc] init];
        [_detailsTextLabel setFont:[UIFont fontWithName:IQ_HELVETICA
                                                   size:(IS_IPAD) ? 14.0f : 13.0f]];
        [_detailsTextLabel setTextColor:IQ_BLACK_COLOR];
        _detailsTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailsTextLabel.backgroundColor = [UIColor clearColor];
        _detailsTextLabel.editable = NO;
        _detailsTextLabel.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _detailsTextLabel.textContainerInset = UIEdgeInsetsZero;
        _detailsTextLabel.contentInset = UIEdgeInsetsZero;
        _detailsTextLabel.scrollEnabled = NO;
        _detailsTextLabel.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
        _detailsTextLabel.linkTextAttributes = @{
                                                 NSForegroundColorAttributeName : IQ_BLUE_COLOR,
                                                 NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle)
                                                 };
        [self addSubview:_detailsTextLabel];
        
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        _singleTapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_singleTapGesture];
    }
    return self;
}

- (void)setActionBlock:(void (^)(TInfoExpandableLineView * view))block {
    _actionBlock = [block copy];
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        
        _expanded = NO;
        
        [self updateUIForState];
    }
}

- (void)setExpanded:(BOOL)expanded {
    if(_expanded != expanded) {
        _expanded = expanded;
        [self updateUIForState];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    CGRect headerRect = CGRectMake(bounds.origin.x + _contentInsets.left,
                                   bounds.origin.y + _contentInsets.top,
                                   bounds.size.width - _contentInsets.left - _contentInsets.right,
                                   HEADER_HEIGHT - _contentInsets.top - _contentInsets.bottom);
    
    CGSize imagSize = (CGSizeEqualToSize(self.imageViewSize, CGSizeZero)) ? self.imageView.image.size : self.imageViewSize;
    self.imageView.frame = CGRectMake(headerRect.origin.x,
                                      headerRect.origin.y + (headerRect.size.height - imagSize.height) / 2.0f,
                                      imagSize.width,
                                      imagSize.height);
    
    CGFloat textX = CGRectRight(self.imageView.frame) + 7.0f;
    CGFloat textHeight = 13.0f;
    self.textLabel.frame = CGRectMake(textX,
                                      headerRect.origin.y + (headerRect.size.height - textHeight) / 2.0f,
                                      headerRect.size.width - textX,
                                      textHeight);
    
    CGFloat detailsY = CGRectBottom(self.textLabel.frame) + 17.0f;
    self.detailsTextLabel.frame = CGRectMake(actualBounds.origin.x,
                                             detailsY,
                                             actualBounds.size.width,
                                             actualBounds.size.height - detailsY);
}

#pragma mark - Private methods

- (void)singleTapRecognized:(UITapGestureRecognizer*)recognizer {
    if (_actionBlock) {
        _actionBlock(self);
    }
}

- (void)updateUIForState {
    if (!_enabled) {
        self.imageView.image = [UIImage imageNamed:@"filter_gray_collapseed.png"];
        self.textLabel.textColor = IQ_FONT_GRAY_COLOR;
    }
    else {
        self.imageView.image = (_expanded) ? [UIImage imageNamed:@"filter_expanded.png"] :
                                             [UIImage imageNamed:@"filter_collapseed.png"];
        self.textLabel.textColor = IQ_BLACK_COLOR;
    }
}

@end
