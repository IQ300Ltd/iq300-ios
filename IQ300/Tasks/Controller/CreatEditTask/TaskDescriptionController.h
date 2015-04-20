//
//  TaskDescriptionController.h
//  IQ300
//
//  Created by Tayphoon on 16.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "PlaceholderTextView.h"
#import "ExtendedButton.h"
#import "TaskFieldEditController.h"

@interface TaskDescriptionController : UIViewController<TaskFieldEditController> {
    UIEdgeInsets _textViewInsets;
}

@property (nonatomic, strong)   NSIndexPath * fieldIndexPath;
@property (nonatomic, strong)   NSString * fieldValue;
@property (nonatomic, weak) id delegate;

@property (nonatomic, readonly) PlaceholderTextView * textView;
@property (nonatomic, readonly) UIView * bottomSeparatorView;
@property (nonatomic, readonly) ExtendedButton * doneButton;

@end
