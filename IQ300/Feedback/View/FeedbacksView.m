//
//  FeedbacksView.m
//  IQ300
//
//  Created by Tayphoon on 01.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbacksView.h"
#import "BottomLineView.h"

#define SEARCH_HEIGHT 38

@interface FeedbacksView() {
    BottomLineView * _searchBarContainer;
}

@end

@implementation FeedbacksView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _searchBarContainer = [[BottomLineView alloc] init];
        _searchBarContainer.backgroundColor = IQ_GRAY_LIGHT_COLOR;
        _searchBarContainer.bottomLineHeight = 0.5f;
        _searchBarContainer.bottomLineColor = IQ_SEPARATOR_LINE_COLOR;
        [self addSubview:_searchBarContainer];
        
        UIImage * searchImage = [UIImage imageNamed:@"search_icon.png"];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:searchImage];
        [imageView setContentMode:UIViewContentModeLeft];
        [imageView setFrame:CGRectMake(0.0f, 0.0f, imageView.frame.size.width + 10.0f, imageView.frame.size.height)];
        
        _clearTextFieldButton = [[UIButton alloc] init];
        [_clearTextFieldButton setImage:[UIImage imageNamed:@"clear_button_icon.png"] forState:UIControlStateNormal];
        [_clearTextFieldButton setFrame:CGRectMake(0, 0, SEARCH_HEIGHT, SEARCH_HEIGHT)];
        
        _searchBar = [[ExTextField alloc] init];
        _searchBar.backgroundColor = [UIColor clearColor];
        _searchBar.textAlignment = NSTextAlignmentLeft;
        _searchBar.placeholderInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 10.0f);
        _searchBar.textInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 10.0f);
        _searchBar.rightView = _clearTextFieldButton;
        _searchBar.rightViewMode = UITextFieldViewModeWhileEditing;
        _searchBar.leftView = imageView;
        _searchBar.leftViewMode = UITextFieldViewModeAlways;
        _searchBar.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Search", nil)
                                                                           attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexInt:0xa9a9a9]}];
        [_searchBar setFont:[UIFont fontWithName:IQ_HELVETICA size:18]];
        [_searchBar setTextColor:[UIColor blackColor]];
        [_searchBarContainer addSubview:_searchBar];
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        if([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        [self addSubview:_tableView];
        [self bringSubviewToFront:_searchBarContainer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _searchBarContainer.frame = CGRectMake(0, 0, self.bounds.size.width, SEARCH_HEIGHT);
    _searchBar.frame = UIEdgeInsetsInsetRect(_searchBarContainer.bounds, UIEdgeInsetsHorizontalMake(7.0f));
    _tableView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(SEARCH_HEIGHT, 0, _tableBottomMargin, 0));
}

- (void)setTableBottomMargin:(CGFloat)tableBottomMargin {
    _tableBottomMargin = tableBottomMargin;
    [self layoutTableView];
}

- (void)layoutTableView {
    _tableView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(SEARCH_HEIGHT, 0, _tableBottomMargin, 0));
}

@end
