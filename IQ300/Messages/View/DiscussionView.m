//
//  DiscussionView.m
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "DiscussionView.h"

#define BORDER_COLOR [UIColor colorWithHexInt:0xe0e1e2]
#define HEADER_HEIGHT 52.0f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]

@interface InputHolderView : UIView

@end

@implementation InputHolderView

- (id)init {
    self = [super init];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.cornerRadius = 4.0f;
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = BORDER_COLOR.CGColor;
        [self setClipsToBounds:YES];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    CGRect attachmentRect = CGRectMake(31.0f,
                                       0.0f,
                                       0.0f,
                                       self.bounds.size.height);
    //Draw attachment line
    CGContextSetStrokeColorWithColor(contex, [BORDER_COLOR CGColor]);
    CGContextSetLineWidth(contex, 0.5);
    CGContextStrokeRect(contex, attachmentRect);
}

@end

@interface CommentInputView() {
    UIView * _inputHolderView;
}

@end

@implementation CommentInputView

- (id)init {
    self = [super init];
    
    if (self) {
        
        _contentInsets = UIEdgeInsetsMakeWithInset(10.0f);
        [self setBackgroundColor:[UIColor colorWithHexInt:0xf6f6f6]];
        
        _inputHolderView = [[InputHolderView alloc] init];

        [self addSubview:_inputHolderView];
        
        _attachButton = [[UIButton alloc] init];
        [_attachButton setImage:[UIImage imageNamed:@"attachment_img.png"] forState:UIControlStateNormal];
        [[_attachButton imageView] setContentMode:UIViewContentModeCenter];
        [_inputHolderView addSubview:_attachButton];
      
        _commentTextView = [[PlaceholderTextView alloc] init];
        [_commentTextView setBackgroundColor:[UIColor clearColor]];
        [_commentTextView setFont:[UIFont fontWithName:IQ_HELVETICA size:15.0f]];
        [_commentTextView setTextColor:[UIColor colorWithHexInt:0x3d3d3d]];
        [_commentTextView setTextContainerInset:UIEdgeInsetsMake(5.0f, 2.0f, 5.0f, 2.0f)];
        [_inputHolderView addSubview:_commentTextView];
        
        _sendButton = [[ExtendedButton alloc] init];
        _sendButton.layer.cornerRadius = 4.0f;
        _sendButton.layer.borderWidth = 0.5f;
        [_sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:12]];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [_sendButton setBackgroundColor:[UIColor colorWithHexInt:0x40b549]];
        [_sendButton setBackgroundColor:[UIColor colorWithHexInt:0x348f3b] forState:UIControlStateHighlighted];
        _sendButton.layer.borderColor = _sendButton.backgroundColor.CGColor;
        [_sendButton setClipsToBounds:YES];
        [self addSubview:_sendButton];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);

    CGSize sendButtonSize = CGSizeMake(75.0f, 34.0f);
    [_sendButton setFrame:CGRectMake(actualBounds.origin.x + (actualBounds.size.width - sendButtonSize.width),
                                     actualBounds.origin.y + (actualBounds.size.height - sendButtonSize.height),
                                     sendButtonSize.width,
                                     sendButtonSize.height)];
    
    CGRect inputRect = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y,
                                  _sendButton.frame.origin.x - actualBounds.origin.x - 10.0f,
                                  actualBounds.size.height);
    
    _inputHolderView.frame = inputRect;
    
    CGRect attachmentRect = CGRectMake(0.0f,
                                       (inputRect.size.height - 31),
                                       31,
                                       31);
    CGSize attachImageSize = [_attachButton imageForState:UIControlStateNormal].size;
    [_attachButton setFrame:CGRectMake(attachmentRect.origin.x + (attachmentRect.size.width - attachImageSize.width) / 2,
                                       attachmentRect.origin.y + (attachmentRect.size.height - attachImageSize.height) / 2,
                                       attachImageSize.width,
                                       attachImageSize.height)];
    
    CGFloat textViewX = CGRectRight(_attachButton.frame) + 5.0f;

    [_commentTextView setFrame:CGRectMake(textViewX,
                                          0.0f,
                                          inputRect.size.width - textViewX,
                                          inputRect.size.height)];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    CGRect toLineRect = CGRectMake(0.0f,
                                   0.0f,
                                   rect.size.width,
                                   0.5f);
    
    //Draw top line
    CGContextSetStrokeColorWithColor(contex, [SEPARATOR_COLOR CGColor]);
    CGContextSetLineWidth(contex, 0.5);
    CGContextStrokeRect(contex, toLineRect);
}

@end

@implementation DiscussionView

- (id)init {
    self = [super init];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _inputHeight = MIN_INPUT_VIEW_HEIGHT;
        _inputOffset = 0.0f;
        
        _headerView = [[BottomLineView alloc] init];
        _headerView.bottomLineColor = SEPARATOR_COLOR;
        _headerView.bottomLineHeight = 0.5f;
        [_headerView setBackgroundColor:[UIColor clearColor]];
        
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"backArrow.png"] forState:UIControlStateNormal];
        [[_backButton imageView] setContentMode:UIViewContentModeCenter];
        [_headerView addSubview:_backButton];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_titleLabel setTextColor:[UIColor colorWithHexInt:0x9f9f9f]];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_headerView addSubview:_titleLabel];
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [_tableView setClipsToBounds:YES];
        if([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        [self addSubview:_tableView];

        [self addSubview:_headerView];

        _inputView = [[CommentInputView alloc] init];
        [self addSubview:_inputView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect actualBounds = self.bounds;
    _headerView.frame = CGRectMake(actualBounds.origin.x,
                                   actualBounds.origin.y,
                                   actualBounds.size.width,
                                   HEADER_HEIGHT);
    
    CGSize backButtonImageSize = [_backButton imageForState:UIControlStateNormal].size;
    _backButton.frame = CGRectMake(13.0f,
                                   actualBounds.origin.y + (_headerView.frame.size.height - backButtonImageSize.height) / 2,
                                   backButtonImageSize.width,
                                   backButtonImageSize.height);
    
    _titleLabel.frame = _headerView.bounds;
    
    CGFloat tableViewY = CGRectBottom(_headerView.frame);
    
    _inputView.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y + (actualBounds.size.height - self.inputHeight) + _inputOffset,
                                  actualBounds.size.width,
                                  self.inputHeight);
    
    _tableView.frame = CGRectMake(actualBounds.origin.x,
                                  tableViewY,
                                  actualBounds.size.width,
                                  _inputView.frame.origin.y - tableViewY);
}

- (void)setInputHeight:(CGFloat)inputHeight {
    _inputHeight = inputHeight;
    [self layoutMessageInputView];
}

- (void)setInputOffset:(CGFloat)inputOffset {
    _inputOffset = inputOffset;
    [self layoutMessageInputView];
}

- (void)layoutMessageInputView {
    CGRect actualBounds = self.bounds;
    _inputView.frame = CGRectMake(actualBounds.origin.x,
                                  actualBounds.origin.y + (actualBounds.size.height - self.inputHeight) + _inputOffset,
                                  actualBounds.size.width,
                                  self.inputHeight);

    CGFloat tableViewY = CGRectBottom(_headerView.frame);
    _tableView.frame = CGRectMake(actualBounds.origin.x,
                                  tableViewY,
                                  actualBounds.size.width,
                                  _inputView.frame.origin.y - tableViewY);
}

@end
