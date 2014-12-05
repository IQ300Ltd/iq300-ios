//
//  DiscussionView.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"
#import "PlaceholderTextView.h"
#import "ExtendedButton.h"

#define MIN_INPUT_VIEW_HEIGHT 54.0f
#define MAX_INPUT_VIEW_HEIGHT 107.0f

@interface CommentInputView : UIView {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) PlaceholderTextView * commentTextView;
@property (nonatomic, readonly) UIButton * attachButton;
@property (nonatomic, readonly) ExtendedButton * sendButton;

@end

@interface DiscussionView : UIView

@property (nonatomic, readonly) BottomLineView * headerView;
@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UIButton * backButton;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, readonly) CommentInputView * inputView;
@property (nonatomic, assign) CGFloat inputHeight;
@property (nonatomic, assign) CGFloat inputOffset;

@end