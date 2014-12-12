//
//  CreateConversationView.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "CreateConversationView.h"

#define HEADER_HEIGHT 52.0f
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
        _contentInsets = UIEdgeInsetsZero;
        _userNameInset = UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 14.0f);
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _headerView = [[BottomLineView alloc] init];
        _headerView.bottomLineColor = [UIColor whiteColor];
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
        [_titleLabel setText:NSLocalizedString(@"Сontacts", nil)];
        [_headerView addSubview:_titleLabel];

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
        [_noDataLabel setHidden:YES];
        [_noDataLabel setText:NSLocalizedString(@"No contacts", nil)];
        [self addSubview:_noDataLabel];

        [self addSubview:_headerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    _headerView.frame = CGRectMake(actualBounds.origin.x,
                                   actualBounds.origin.y,
                                   actualBounds.size.width,
                                   HEADER_HEIGHT);
    
    CGSize backButtonImageSize = [_backButton imageForState:UIControlStateNormal].size;
    _backButton.frame = CGRectMake(13.0f,
                                   actualBounds.origin.y + (_headerView.frame.size.height - backButtonImageSize.height) / 2,
                                   backButtonImageSize.width,
                                   backButtonImageSize.height);

    _titleLabel.frame = _headerView.bounds;
    
    CGRect containerRect = CGRectMake(actualBounds.origin.x,
                                      CGRectBottom(_headerView.frame),
                                      actualBounds.size.width,
                                      29.0f);
    _userNamelContainer.frame = UIEdgeInsetsInsetRect(containerRect, _userNameInset);
    
    CGFloat tableViewY = CGRectBottom(_userNamelContainer.frame);
    _tableView.frame = CGRectMake(actualBounds.origin.x,
                                  tableViewY,
                                  actualBounds.size.width,
                                  actualBounds.size.height - tableViewY);
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
