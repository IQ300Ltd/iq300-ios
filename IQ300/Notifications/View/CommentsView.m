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
        
        _inputView = [[CommentInputView alloc] init];
        [self addSubview:_inputView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    
    CGFloat tableViewY = actualBounds.origin.y;
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
    
    CGFloat tableViewY = actualBounds.origin.y;
    _tableView.frame = CGRectMake(actualBounds.origin.x,
                                  tableViewY,
                                  actualBounds.size.width,
                                  _inputView.frame.origin.y - tableViewY);
}

@end
