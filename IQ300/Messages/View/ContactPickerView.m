//
//  CreateConversationView.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "ContactPickerView.h"

#define HEADER_HEIGHT 60.0f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xc0c0c0]
#define BOTTOM_VIEW_HEIGHT 60

@interface ContactPickerView() {
    BottomLineView * _userNamelContainer;
    UIEdgeInsets _userNameInset;
    UIView * _bottomSeparatorView;
}

@end

@implementation ContactPickerView

- (id)init {
    self = [super init];
    
    if (self) {
        _contentInsets = UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f);
        _userNameInset = UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 14.0f);
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _clearTextFieldButton = [[UIButton alloc] init];
        [_clearTextFieldButton setImage:[UIImage imageNamed:@"clear_button_icon.png"] forState:UIControlStateNormal];
        [_clearTextFieldButton setFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
        
        _userTextField = [[ExTextField alloc] init];
        _userTextField.rightView = _clearTextFieldButton;
        _userTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _userTextField.placeholderInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 20.0f);
        _userTextField.textInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 20.0f);
        _userNamelContainer = [self makeContainerWithField:_userTextField placeholder:@"User name or email"];
        [self addSubview:_userNamelContainer];
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = SEPARATOR_COLOR;
        [_tableView setClipsToBounds:YES];
        if([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        [self addSubview:_tableView];
        
        _bottomSeparatorView = [[UIView alloc] init];
        [_bottomSeparatorView setBackgroundColor:SEPARATOR_COLOR];
        [self addSubview:_bottomSeparatorView];
        
        _doneButton = [[ExtendedButton alloc] init];
        _doneButton.layer.cornerRadius = 4.0f;
        _doneButton.layer.borderWidth = 0.5f;
        [_doneButton setTitle:NSLocalizedString(@"Create", nil) forState:UIControlStateNormal];
        [_doneButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [_doneButton setBackgroundColor:IQ_CELADON_COLOR];
        [_doneButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
        [_doneButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
        _doneButton.layer.borderColor = _doneButton.backgroundColor.CGColor;
        [_doneButton setClipsToBounds:YES];
        [self addSubview:_doneButton];

        
        _noDataLabel = [[UILabel alloc] init];
        [_noDataLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_noDataLabel setTextColor:[UIColor colorWithHexInt:0xb3b3b3]];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.backgroundColor = [UIColor clearColor];
        _noDataLabel.numberOfLines = 0;
        _noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_noDataLabel setText:NSLocalizedString(@"No contacts", nil)];
        [self addSubview:_noDataLabel];
    }
    return self;
}

- (void)setDoneButtonHidden:(BOOL)doneButtonHidden {
    _doneButtonHidden = doneButtonHidden;
    _doneButton.hidden = doneButtonHidden;
    _bottomSeparatorView.hidden = doneButtonHidden;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    
    CGRect containerRect = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      29.0f);
    _userNamelContainer.frame = UIEdgeInsetsInsetRect(containerRect, _userNameInset);
    
    [self layoutTableView];
}

- (void)setTableBottomMargin:(CGFloat)tableBottomMargin {
    _tableBottomMargin = tableBottomMargin;
    [self layoutTableView];
}

- (void)layoutTableView {
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    
    if (!self.doneButtonHidden) {
        _bottomSeparatorView.frame = CGRectMake(actualBounds.origin.x,
                                                actualBounds.origin.y + actualBounds.size.height - BOTTOM_VIEW_HEIGHT - _tableBottomMargin,
                                                actualBounds.size.width,
                                                0.5f);
        
        CGSize clearButtonSize = CGSizeMake(300, 40);
        _doneButton.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - clearButtonSize.width) / 2.0f,
                                       actualBounds.origin.y + actualBounds.size.height - clearButtonSize.height - 10.0f - _tableBottomMargin,
                                       clearButtonSize.width,
                                       clearButtonSize.height);
    }

    CGFloat bottomInset = (self.isDoneButtonHidden) ? 0.0f : BOTTOM_VIEW_HEIGHT;
    CGFloat tableViewY = CGRectBottom(_userNamelContainer.frame);
    _tableView.frame = CGRectMake(actualBounds.origin.x,
                                  tableViewY,
                                  actualBounds.size.width,
                                  actualBounds.origin.y + actualBounds.size.height - tableViewY - _tableBottomMargin - bottomInset);
    _noDataLabel.frame = _tableView.frame;
}

- (BottomLineView*)makeContainerWithField:(ExTextField*)textField placeholder:(NSString*)placeholder {
    BottomLineView * containerView = [[BottomLineView alloc] init];
    containerView.bottomLineColor = SEPARATOR_COLOR;
    containerView.bottomLineHeight = 0.5f;
    [containerView setBackgroundColor:[UIColor clearColor]];
    
    textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textField.font = [UIFont fontWithName:IQ_HELVETICA size:16];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(placeholder, nil)
                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexInt:0x8d8c8d]}];
    
    [containerView addSubview:textField];
    return containerView;
}

@end
