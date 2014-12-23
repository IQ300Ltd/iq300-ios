//
//  CSectionHeaderView.m
//  IQ300
//
//  Created by Tayphoon on 20.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "CSectionHeaderView.h"

#define CENTER_LINE_COLOR [UIColor colorWithHexInt:0xcccccc]
#define CENTER_LINE_HEIGHT 0.5f

@interface CSectionHeaderView() {
    UILabel * _titleLabel;
}

@end

@implementation CSectionHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _contentInsets = UIEdgeInsetsZero;
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:12]];
        [_titleLabel setTextColor:[UIColor colorWithHexInt:0x9f9f9f]];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGRect mainRect = UIEdgeInsetsInsetRect(rect, _contentInsets);
    
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    CGRect bottomLine = CGRectMake(mainRect.origin.x,
                                   mainRect.origin.y + rect.size.height / 2.0f + CENTER_LINE_HEIGHT * 0.5f,
                                   mainRect.size.width,
                                   CENTER_LINE_HEIGHT);
    
    //Draw bottom line
    CGContextSetStrokeColorWithColor(contex, [CENTER_LINE_COLOR CGColor]);
    CGContextSetLineWidth(contex, CENTER_LINE_HEIGHT);
    CGContextStrokeRect(contex, bottomLine);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    CGRect mainRect = UIEdgeInsetsInsetRect(actualBounds, _contentInsets);
    CGFloat titleSize = 66;
    
    _titleLabel.frame = CGRectMake(mainRect.origin.x + (mainRect.size.width - titleSize) / 2,
                                   mainRect.origin.y,
                                   titleSize,
                                   mainRect.size.height);
}

- (void)setTitle:(NSString *)title {
    [_titleLabel setText:title];
}

- (NSString*)title {
    return _titleLabel.text;
}

@end
