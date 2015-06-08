//
//  TInfoLineView.m
//  IQ300
//
//  Created by Tayphoon on 18.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TInfoLineView.h"

#define HORIZONTAL_PADDING 10
#define VERTICAL_PADDING 0
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xc0c0c0]

@implementation TInfoLineView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setClipsToBounds:YES];
        
        _contentInsets = UIEdgeInsetsMake(VERTICAL_PADDING, HORIZONTAL_PADDING, VERTICAL_PADDING, HORIZONTAL_PADDING);
        
        self.bottomLineHeight = 0.5f;
        self.bottomLineColor = SEPARATOR_COLOR;
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont fontWithName:IQ_HELVETICA
                                          size:(IS_IPAD) ? 14.0f : 13.0f];
        _textLabel.textColor = [UIColor colorWithHexInt:0x20272a];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGSize imagSize = (CGSizeEqualToSize(self.imageViewSize, CGSizeZero)) ? _imageView.image.size : self.imageViewSize;
    _imageView.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y + (actualBounds.size.height - imagSize.height) / 2.0f,
                                  imagSize.width,
                                  imagSize.height);
    
    CGFloat textX = CGRectRight(_imageView.frame) + 7.0f;
    _textLabel.frame = CGRectMake(textX,
                                  actualBounds.origin.y,
                                  actualBounds.size.width - textX,
                                  actualBounds.size.height);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef contex = UIGraphicsGetCurrentContext();
    if (self.drawLeftSeparator) {
        CGRect bottomLine = CGRectMake(rect.origin.x - 0.5f,
                                       rect.origin.y,
                                       0.5f,
                                       rect.size.height);
        
        //Draw left line
        CGContextSetStrokeColorWithColor(contex, SEPARATOR_COLOR.CGColor);
        CGContextSetLineWidth(contex, 0.5f);
        CGContextStrokeRect(contex, bottomLine);
    }
    
    if (self.drawTopSeparator) {
        CGRect bottomLine = CGRectMake(rect.origin.x,
                                       rect.origin.y - 0.5f,
                                       rect.size.width,
                                       0.5f);
        
        //Draw left line
        CGContextSetStrokeColorWithColor(contex, SEPARATOR_COLOR.CGColor);
        CGContextSetLineWidth(contex, 0.5f);
        CGContextStrokeRect(contex, bottomLine);
    }
}

- (void)setDrawLeftSeparator:(BOOL)drawLeftSeparator {
    if (_drawLeftSeparator != drawLeftSeparator) {
        _drawLeftSeparator = drawLeftSeparator;
        [self setNeedsDisplay];
    }
}

- (CGFloat)heightConstrainedToSize:(CGSize)size {
    CGSize textLabelSize = [_textLabel.text sizeWithFont:_textLabel.font
                                       constrainedToSize:size
                                           lineBreakMode:NSLineBreakByWordWrapping];

    return textLabelSize.height + HORIZONTAL_PADDING * 2.0f;
}

@end
