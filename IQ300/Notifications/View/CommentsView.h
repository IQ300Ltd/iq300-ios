//
//  CommentsView.h
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomLineView.h"
#import "CommentInputView.h"

@interface CommentsView : UIView

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, readonly) CommentInputView * inputView;
@property (nonatomic, assign) CGFloat inputHeight;
@property (nonatomic, assign) CGFloat inputOffset;

@end
