//
//  TInfoHeaderView.h
//  IQ300
//
//  Created by Tayphoon on 18.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TInfoExpandableLineView.h"

@class IQTask;
@class TInfoHeaderView;

@protocol TInfoHeaderViewDelegate <NSObject>

@optional

- (void)headerView:(TInfoHeaderView*)headerView tapActionAtIndex:(NSInteger)actionIndex actionButton:(UIButton*)actionButton;

@end

@interface TInfoHeaderView : UIView

+ (CGFloat)heightForTask:(IQTask*)task width:(CGFloat)width descriptionExpanded:(BOOL)descriptionExpanded;

@property (nonatomic, readonly) UILabel * taskIDLabel;
@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UILabel * fromLabel;
@property (nonatomic, readonly) UILabel * toLabel;

@property (nonatomic, strong) UILabel *parentTaskLabel;
@property (nonatomic, strong) UIButton *parentTaskButton;

@property (nonatomic, readonly) TInfoExpandableLineView * descriptionView;
@property (nonatomic, readonly) TInfoLineView * statusView;
@property (nonatomic, readonly) TInfoLineView * dueDateView;
@property (nonatomic, readonly) TInfoLineView * projectInfoView;
@property (nonatomic, readonly) TInfoLineView * communityInfoView;
@property (nonatomic, readonly) TInfoLineView * reconciliationInfoView;

@property (nonatomic, readonly) TInfoLineView *complexityInfoView;
@property (nonatomic, readonly) TInfoLineView *estimatedTimeInfoView;

@property (nonatomic, weak) id<TInfoHeaderViewDelegate> delegate;

- (void)setupByTask:(IQTask*)task;

- (UIButton*)actionButtonAtIndex:(NSInteger)actionIndex;

@end
