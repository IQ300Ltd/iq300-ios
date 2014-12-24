//
//  CommentInputView.h
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"
#import "ExtendedButton.h"

#define MIN_INPUT_VIEW_HEIGHT 54.0f
#define MAX_INPUT_VIEW_HEIGHT 107.0f

#define ATTACHMENT_IMG @"attachment_img.png"
#define ATTACHMENT_ADD_IMG @"attachment_add_img.png"

@interface CommentInputView : UIView {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) PlaceholderTextView * commentTextView;
@property (nonatomic, readonly) UIButton * attachButton;
@property (nonatomic, readonly) ExtendedButton * sendButton;

@end

