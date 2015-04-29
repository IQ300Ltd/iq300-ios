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

@interface CreateConversationView : UIView {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) ExTextField * userTextField;
@property (nonatomic, readonly) UIButton * clearTextFieldButton;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, assign) CGFloat tableBottomMargin;

@property (nonatomic, strong) UILabel * noDataLabel;

@end
