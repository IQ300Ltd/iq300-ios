//
//  ExecutersGroupSection.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "ExecutersGroupSection.h"

#define ACCESSORY_VIEW_SIZE 14.0f
#define TITLE_OFFSET 10.0f

@interface ExecutersGroupSection() {
    UITapGestureRecognizer * _singleTapGesture;
}

@end

@implementation ExecutersGroupSection

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _contentInsets = UIEdgeInsetsMakeWithInset(13.0f);
        [self setBackgroundColor:[UIColor colorWithHexInt:0xf6f6f6]];
        
        _showLeftView = YES;
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = [UIColor colorWithHexInt:0x4288a7];
        [self addSubview:_leftView];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA_BOLD size:16]];
        [_titleLabel setTextColor:[UIColor colorWithHexInt:0x9f9f9f]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];
        
        _accessoryImageView = [[UIImageView alloc] init];
        [self addSubview:_accessoryImageView];
        
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
        _singleTapGesture.numberOfTapsRequired = 1;
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
    
    CGSize accessorySize = CGSizeMake(ACCESSORY_VIEW_SIZE, ACCESSORY_VIEW_SIZE);
    _accessoryImageView.frame = CGRectMake(mainRect.origin.x + mainRect.size.width - accessorySize.width,
                                           mainRect.origin.y + (mainRect.size.height - accessorySize.height) / 2.0f,
                                           accessorySize.width,
                                           accessorySize.height);

    
    CGFloat titleWidth = mainRect.size.width - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
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
    _selected = !_selected;
    [self updateUIForState];
    
    if (_actionBlock) {
        _actionBlock(self);
    }
}

- (void)updateUIForState {
    _accessoryImageView.image = (_selected) ? [UIImage imageNamed:@"filterSelected"] : nil;
}

@end
