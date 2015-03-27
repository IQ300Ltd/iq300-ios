//
//  TInfoHeaderView.m
//  IQ300
//
//  Created by Tayphoon on 18.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "TInfoHeaderView.h"
#import "IQTask.h"
#import "NSDate+IQFormater.h"
#import "IQUser.h"
#import "IQCommunity.h"
#import "TaskHelper.h"
#import "IQProject.h"
#import "TaskHelper.h"
#import "ExtendedButton.h"

#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:15.0f]
#define LINE_HEIGHT 45.5f
#define HORIZONTAL_PADDING 10.0f
#define TASK_ID_HEIGHT 11.0f
#define TITLE_OFFSET 2.5f
#define USER_OFFSET 5.0f
#define USER_HEIGHT 13.0f

#define BUTTON_VERTICAL_PADDING 22.0f
#define BUTTON_HEIGHT 40.0f
#define BUTTON_OFFSET 13.0f

@interface TInfoHeaderView() {
    UIEdgeInsets _headerInsets;
    BottomLineView * _buttonsHolder;
}

@end

@implementation TInfoHeaderView

+ (CGFloat)heightForTask:(IQTask*)task width:(CGFloat)width {
    CGFloat hederWidth = width - 10.0f - 7.0f;
    CGFloat height = HORIZONTAL_PADDING * 2 + TASK_ID_HEIGHT + TITLE_OFFSET + USER_OFFSET + USER_HEIGHT + LINE_HEIGHT;
    
    CGSize titleLabelSize = [task.title sizeWithFont:TITLE_FONT
                                         constrainedToSize:CGSizeMake(hederWidth, CGFLOAT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
    
    height += titleLabelSize.height;
    
    if([task.community.title length] > 0) {
        height += LINE_HEIGHT;
    }
    
    if([task.project.title length] > 0) {
        height += LINE_HEIGHT;
    }
    
    if ([task.availableActions count] > 0) {
        height += BUTTON_VERTICAL_PADDING * 2.0f + (BUTTON_OFFSET + BUTTON_HEIGHT) * [task.availableActions count] - BUTTON_OFFSET;
    }

    return height;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];

        _headerInsets = UIEdgeInsetsMake(HORIZONTAL_PADDING, 10, HORIZONTAL_PADDING, 7);
        
        _taskIDLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                               font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                      localaizedKey:nil];
        _taskIDLabel.numberOfLines = 1;
        [self addSubview:_taskIDLabel];
        
        _titleLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x20272a]
                                              font:TITLE_FONT
                                     localaizedKey:nil];
        [self addSubview:_titleLabel];

        _fromLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                             font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                    localaizedKey:nil];
        _fromLabel.numberOfLines = 1;
        [self addSubview:_fromLabel];
        
        _toLabel = [self makeLabelWithTextColor:[UIColor colorWithHexInt:0x9f9f9f]
                                           font:[UIFont fontWithName:IQ_HELVETICA size:11.0f]
                                  localaizedKey:nil];
        _toLabel.numberOfLines = 1;
        [self addSubview:_toLabel];

        _statusView = [[TInfoLineView alloc] init];
        _statusView.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        _statusView.drawTopSeparator = YES;
        [_statusView.imageView setImage:[UIImage imageNamed:@"task_status_ico.png"]];
        [self addSubview:_statusView];
        
        _dueDateView = [[TInfoLineView alloc] init];
        _dueDateView.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        [_dueDateView.imageView setImage:[UIImage imageNamed:@"bell_ico.png"]];
        _dueDateView.drawTopSeparator = YES;
        _dueDateView.drawLeftSeparator = YES;
        [self addSubview:_dueDateView];
        
        _projectInfoView = [[TInfoLineView alloc] init];
        _projectInfoView.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        [_projectInfoView.imageView setImage:[UIImage imageNamed:@"project_ico.png"]];
        [self addSubview:_projectInfoView];

        CGFloat icoSize = 17.0f;
        _communityInfoView = [[TInfoLineView alloc] init];
        _communityInfoView.backgroundColor = [UIColor colorWithHexInt:0xf6f6f6];
        _communityInfoView.imageViewSize = CGSizeMake(icoSize, icoSize);
        _communityInfoView.imageView.layer.cornerRadius = icoSize / 2.0f;
        _communityInfoView.imageView.clipsToBounds = YES;
        [_communityInfoView.imageView setImage:[UIImage imageNamed:@"community_ico.png"]];
        [self addSubview:_communityInfoView];
        
        _buttonsHolder = [[BottomLineView alloc] init];
        _buttonsHolder.bottomLineHeight = 0.5f;
        _buttonsHolder.bottomLineColor = [UIColor colorWithHexInt:0xc0c0c0];
        [_buttonsHolder setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_buttonsHolder];
    }
    
    return self;
}

- (void)setupByTask:(IQTask *)task {
    _taskIDLabel.text = [NSString stringWithFormat:@"#%@", task.taskId];
    _titleLabel.text = task.title;
    _fromLabel.text = task.customer.displayName;
    _toLabel.text = [NSString stringWithFormat:@"> %@", task.executor.displayName];
    
    _statusView.textLabel.textColor = [TaskHelper colorForTaskType:task.status];
    _statusView.textLabel.text = NSLocalizedString(task.status, nil);

    _dueDateView.textLabel.text = [task.endDate dateToDayString];

    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.maximumLineHeight = [_communityInfoView.textLabel.font pointSize];
    paragraphStyle.minimumLineHeight = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.lineSpacing = 0.0f;
    
    NSDictionary * attributes = @{ NSForegroundColorAttributeName : _communityInfoView.textLabel.textColor,
                                   NSFontAttributeName            : _communityInfoView.textLabel.font ,
                                   NSParagraphStyleAttributeName  : paragraphStyle };
    
    if([task.community.title length] > 0) {
        _communityInfoView.textLabel.attributedText = [[NSAttributedString alloc] initWithString:task.community.title
                                                                                      attributes:attributes];
    }
    if([task.project.title length] > 0) {
        _projectInfoView.textLabel.attributedText = [[NSAttributedString alloc] initWithString:task.project.title
                                                                                    attributes:attributes];
    }
    
    if([task.community.thumbUrl length] > 0) {
        [_communityInfoView.imageView sd_setImageWithURL:[NSURL URLWithString:task.community.thumbUrl]
                                        placeholderImage:[UIImage imageNamed:@"community_ico.png"]];
    }
    
    [[_buttonsHolder subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSInteger i = [task.availableActions count] - 1; i >= 0; i--) {
        NSString * actionType = [task.availableActions allObjects][i];
        BOOL isPositiveAction = [TaskHelper isPositiveActionWithType:actionType];
        ExtendedButton * actionButton = [[ExtendedButton alloc] init];
        actionButton.layer.cornerRadius = 3.0f;
        if(!isPositiveAction) {
            actionButton.layer.borderWidth = 0.5f;
            actionButton.layer.borderColor = [UIColor colorWithHexInt:0xd0d0d0].CGColor;
            [actionButton setTitleColor:[UIColor colorWithHexInt:0x338cae] forState:UIControlStateNormal];
            [actionButton setBackgroundColor:[UIColor whiteColor]];
            [actionButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [actionButton setBorderColor:IQ_CELADON_COLOR forState:UIControlStateHighlighted];
        }
        else {
            [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
            [actionButton setBackgroundColor:IQ_CELADON_COLOR];
            [actionButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
            [actionButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
        }
        
        [actionButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        actionButton.titleLabel.font = [UIFont fontWithName:IQ_HELVETICA size:16];
        [actionButton setTitle:NSLocalizedString([TaskHelper displayNameForActionType:actionType], nil)
                      forState:UIControlStateNormal];
        [actionButton setClipsToBounds:YES];
        actionButton.tag = i;
        
        if(isPositiveAction) {
            [_buttonsHolder insertSubview:actionButton atIndex:0];
        }
        else {
            [_buttonsHolder addSubview:actionButton];
        }
    }
    
    [self setNeedsLayout];
}

- (UIButton*)actionButtonAtIndex:(NSInteger)actionIndex {
    if(actionIndex > 0 && actionIndex < [_buttonsHolder.subviews count]) {
        return _buttonsHolder.subviews[actionIndex];
    }
    return nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect headerBounds = UIEdgeInsetsInsetRect(bounds, _headerInsets);
    
    _taskIDLabel.frame = CGRectMake(headerBounds.origin.x,
                                    headerBounds.origin.y,
                                    headerBounds.size.width,
                                    TASK_ID_HEIGHT);
    
    CGSize titleLabelSize = [_titleLabel.text sizeWithFont:_titleLabel.font
                                         constrainedToSize:CGSizeMake(headerBounds.size.width, CGFLOAT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
    _titleLabel.frame = CGRectMake(headerBounds.origin.x,
                                   CGRectBottom(_taskIDLabel.frame) + TITLE_OFFSET,
                                   headerBounds.size.width,
                                   titleLabelSize.height);
    
    CGRect usersLabelFrame = CGRectMake(headerBounds.origin.x,
                                        CGRectBottom(_titleLabel.frame) + USER_OFFSET,
                                        headerBounds.size.width,
                                        USER_HEIGHT);
    
    CGFloat userMaxWidth = usersLabelFrame.size.width / 2.0f;
    CGSize userLabelSize = [_fromLabel.text sizeWithFont:_fromLabel.font
                                       constrainedToSize:CGSizeMake(userMaxWidth, usersLabelFrame.size.height)
                                           lineBreakMode:_fromLabel.lineBreakMode];
    BOOL needOffset = (userLabelSize.width <= userMaxWidth - 5.0f);
    CGFloat userLabelWidth = MIN(userLabelSize.width, userMaxWidth);
    
    _fromLabel.frame = CGRectMake(usersLabelFrame.origin.x,
                                  usersLabelFrame.origin.y,
                                  userLabelWidth,
                                  usersLabelFrame.size.height);
    
    _toLabel.frame = CGRectMake(CGRectRight(_fromLabel.frame) + ((needOffset) ? 5.0f : 0.0f),
                                usersLabelFrame.origin.y,
                                usersLabelFrame.size.width / 2.0f,
                                usersLabelFrame.size.height);
    
    CGSize statusDueSize = CGSizeMake(bounds.size.width / 2.0f, LINE_HEIGHT);
    
    _statusView.frame = CGRectMake(bounds.origin.x,
                                   CGRectBottom(_fromLabel.frame) + _headerInsets.bottom,
                                   statusDueSize.width,
                                   statusDueSize.height);
    _dueDateView.frame = CGRectMake(CGRectRight(_statusView.frame),
                                    _statusView.frame.origin.y,
                                    statusDueSize.width,
                                    statusDueSize.height);

    if ([_projectInfoView.textLabel.text length] > 0) {
        _projectInfoView.frame = CGRectMake(bounds.origin.x,
                                            CGRectBottom(_statusView.frame),
                                            bounds.size.width,
                                            LINE_HEIGHT);
    }
    else {
        _projectInfoView.frame = CGRectMake(bounds.origin.x,
                                            CGRectBottom(_statusView.frame),
                                            bounds.size.width,
                                            0.0f);
    }
    
    if ([_communityInfoView.textLabel.text length] > 0) {
        _communityInfoView.frame = CGRectMake(bounds.origin.x,
                                              CGRectBottom(_projectInfoView.frame),
                                              bounds.size.width,
                                              LINE_HEIGHT);
    }
    else {
        _communityInfoView.frame = CGRectMake(bounds.origin.x,
                                              CGRectBottom(_projectInfoView.frame),
                                              bounds.size.width,
                                              0.0f);
    }
    
    CGRect buttonsHolderRect = CGRectMake(bounds.origin.x,
                                          CGRectBottom(_communityInfoView.frame),
                                          bounds.size.width,
                                          0);
    
    if([[_buttonsHolder subviews] count] > 0) {
        CGFloat buttonsHolderHeight = BUTTON_VERTICAL_PADDING * 2.0f + (BUTTON_OFFSET + BUTTON_HEIGHT) * [[_buttonsHolder subviews] count] - BUTTON_OFFSET;
        buttonsHolderRect.size.height = buttonsHolderHeight;
        _buttonsHolder.frame = buttonsHolderRect;
        
        CGFloat buttonY = BUTTON_VERTICAL_PADDING;
        for (UIView * view in [_buttonsHolder subviews]) {
            view.frame = CGRectMake(BUTTON_OFFSET,
                                    buttonY,
                                    _buttonsHolder.frame.size.width - BUTTON_OFFSET * 2,
                                    BUTTON_HEIGHT);
            buttonY = CGRectBottom(view.frame) + BUTTON_OFFSET;
        }
    }
}

- (void)buttonAction:(UIButton*)button {
    if([self.delegate respondsToSelector:@selector(headerView:tapActionAtIndex:actionButton:)]) {
        [self.delegate headerView:self tapActionAtIndex:button.tag actionButton:button];
    }
}

- (UILabel*)makeLabelWithTextColor:(UIColor*)textColor font:(UIFont*)font localaizedKey:(NSString*)localaizedKey {
    UILabel * label = [[UILabel alloc] init];
    [label setFont:font];
    [label setTextColor:textColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    if(localaizedKey) {
        [label setText:NSLocalizedString(localaizedKey, nil)];
    }
    return label;
}

@end
