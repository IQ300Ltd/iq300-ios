//
//  CommentsView.m
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "CommentsView.h"

#define HEADER_HEIGHT 52.0f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]

@implementation CommentsView

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
    _backButton.frame = CGRectMake(-4.0f,
                                   actualBounds.origin.y + (_headerView.frame.size.height - backButtonImageSize.height) / 2,
                                   backButtonImageSize.width,
                                   backButtonImageSize.height);
    
    _titleLabel.frame = CGRectMake(CGRectRight(_backButton.frame),
                                   0.0f,
                                   _headerView.frame.size.width - CGRectRight(_backButton.frame) * 2.0f,
                                   _headerView.frame.size.height);
    
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
