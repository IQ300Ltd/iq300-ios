//
//  TaskFilterSectionView.m
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskFilterSectionView.h"
#import "ExtendedButton.h"
#import "TaskFilterConst.h"

#define SEPARATOR_HEIGHT 0.5f

@interface TaskFilterSectionView() {
    ExtendedButton * _backgroundView;
    UIButton * _sortButton;
    BOOL _isExpandable;
    UIEdgeInsets _backgroundViewInsets;
    UIView * _topSeparatorView;
}

@end

@implementation TaskFilterSectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _backgroundViewInsets = UIEdgeInsetsMake(0, 0, 1, 0);
        CGFloat spacing = 13;
        
        _backgroundView = [ExtendedButton new];
        _backgroundView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backgroundView.contentEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
        _backgroundView.titleEdgeInsets = UIEdgeInsetsMake(0, 10.0f, 0, 0);
        [_backgroundView setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backgroundView setBackgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_backgroundView setImage:[UIImage imageNamed:@"filter_collapseed.png"] forState:UIControlStateNormal];
        [_backgroundView.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
        
        [_backgroundView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backgroundView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundView];
        
        _sortButton = [[UIButton alloc] init];
        [_sortButton setImage:[UIImage imageNamed:@"asc_sort_ico.png"] forState:UIControlStateNormal];
        [_sortButton addTarget:self action:@selector(sortButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sortButton];
        
        _topSeparatorView = [[UIView alloc] init];
        [_topSeparatorView setBackgroundColor:SEPARATOR_COLOR];
        [self addSubview:_topSeparatorView];
        
        _expanded = NO;
        _sortAvailable = NO;
        _ascending = YES;
        [self updateUIForState];
        [self updateSortViewForState];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    [_backgroundView setTitle:title forState:UIControlStateNormal];
}

- (void)setActionBlock:(void (^)(TaskFilterSectionView*))block {
    _actionBlock = [block copy];
}

- (void)setSortActionBlock:(void (^)(TaskFilterSectionView* header))block {
    _sortActionBlock = [block copy];
}

- (void)setExpandable:(BOOL)expandable {
    if(_isExpandable != expandable) {
        _isExpandable = expandable;
        [self updateUIForState];
    }
}

- (void)setExpanded:(BOOL)expanded {
    if(_expanded != expanded) {
        _expanded = expanded;
        [self updateUIForState];
    }
}

- (void)setSortAvailable:(BOOL)sortAvailable {
    if(_sortAvailable != sortAvailable) {
        _sortAvailable = sortAvailable;
        [self updateSortViewForState];
    }
}

- (void)setAscending:(BOOL)ascending {
    if(_ascending != ascending) {
        _ascending = ascending;
        [self updateSortViewForState];
    }
}

- (void)setSeparatorHidden:(BOOL)hidden {
    _topSeparatorView.hidden = hidden;
}

- (NSString*)title {
    return [_backgroundView titleForState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;
    CGRect backgroundViewRect = UIEdgeInsetsInsetRect(actualBounds, _backgroundViewInsets);
    _backgroundView.frame = backgroundViewRect;
    
    _sortButton.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - actualBounds.size.height,
                                   actualBounds.origin.y,
                                   actualBounds.size.height,
                                   actualBounds.size.height);
    
    _topSeparatorView.frame = CGRectMake(actualBounds.origin.x,
                                         actualBounds.origin.y,
                                         actualBounds.size.width,
                                         SEPARATOR_HEIGHT);
}

- (void)buttonAction:(UIButton*)sender {
    _expanded = !_expanded;
    if(_actionBlock) {
        _actionBlock(self);
    }
    [self updateUIForState];
}

- (void)sortButtonAction:(UIButton*)sender {
    _ascending = !_ascending;
    if(_sortActionBlock) {
        _sortActionBlock(self);
    }
    [self updateSortViewForState];
}

- (void)updateUIForState {    
    if(_isExpandable) {
        _backgroundView.titleEdgeInsets = (_expanded) ? UIEdgeInsetsMake(0, 4.0f, 0, 0) : UIEdgeInsetsMake(0, 10.0f, 0, 0);
        [_backgroundView setImage:(_expanded) ? [UIImage imageNamed:@"filter_expanded.png"] : [UIImage imageNamed:@"filter_collapseed.png"]
                         forState:UIControlStateNormal];
    }
    else {
        _backgroundView.titleEdgeInsets = UIEdgeInsetsZero;
        [_backgroundView setImage:nil forState:UIControlStateNormal];
    }
}

- (void)updateSortViewForState {
    [_sortButton setHidden:!_sortAvailable];
    if (_sortAvailable) {
        [_sortButton setImage:(_ascending) ? [UIImage imageNamed:@"asc_sort_ico.png"] : [UIImage imageNamed:@"desc_sort_ico.png"]
                         forState:UIControlStateNormal];
    }
}

@end
