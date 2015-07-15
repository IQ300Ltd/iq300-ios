//
//  CreateConversationView.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExTextField.h"
#import "BottomLineView.h"
#import "ExtendedButton.h"

@interface ContactPickerView : UIView {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) ExTextField * userTextField;
@property (nonatomic, readonly) ExtendedButton * doneButton;
@property (nonatomic, readonly) UIButton * clearTextFieldButton;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, assign) CGFloat tableBottomMargin;
@property (nonatomic, assign, getter = isDoneButtonHidden) BOOL doneButtonHidden;

@property (nonatomic, strong) UILabel * noDataLabel;

@end