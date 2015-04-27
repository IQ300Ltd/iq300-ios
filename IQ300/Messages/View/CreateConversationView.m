//
//  CreateConversationView.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "CreateConversationView.h"

#define HEADER_HEIGHT 60.0f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xc0c0c0]

@interface CreateConversationView() {
    BottomLineView * _userNamelContainer;
    UIEdgeInsets _userNameInset;
}

@end

@implementation CreateConversationView

- (id)init {
    self = [super init];
    
    if (self) {
        _contentInsets = UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f);
        _userNameInset = UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 14.0f);
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _userTextField = [[ExTextField alloc] init];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    
    CGRect containerRect = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      29.0f);
    _userNamelContainer.frame = UIEdgeInsetsInsetRect(containerRect, _userNameInset);
    
    CGFloat tableViewY = CGRectBottom(_userNamelContainer.frame);
    _tableView.frame = CGRectMake(actualBounds.origin.x,
                                  tableViewY,
                                  actualBounds.size.width,
                                  actualBounds.size.height - tableViewY - _tableBottomMargin);
    _noDataLabel.frame = _tableView.frame;
}

- (void)setTableBottomMargin:(CGFloat)tableBottomMargin {
    _tableBottomMargin = tableBottomMargin;
    [self layoutTableView];
}

- (void)layoutTableView {
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    CGFloat tableViewY = CGRectBottom(_userNamelContainer.frame);
    _tableView.frame = CGRectMake(actualBounds.origin.x,
                                  tableViewY,
                                  actualBounds.size.width,
                                  actualBounds.size.height - tableViewY - _tableBottomMargin);
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
