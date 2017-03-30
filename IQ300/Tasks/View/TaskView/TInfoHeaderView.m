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
#import "IQReconciliation.h"
#import "IQComplexity.h"

#define LINE_HEIGHT 45.5f
#define CONTENT_LEFT_INSET 10.0f
#define CONTENT_RIGHT_INSET 10.0f
#define USER_OFFSET 5.0f

#define BUTTON_VERTICAL_PADDING 22.0f
#define BUTTON_HEIGHT 40.0f
#define BUTTON_WIDTH 215.0f
#define BUTTON_OFFSET 13.0f

#ifdef IPAD
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:17.0f]
#define DESCRIPTION_FONT [UIFont fontWithName:IQ_HELVETICA size:14.0f]
#define TASK_ID_HEIGHT 16.0f
#define LABEL_FONT_SIZE 14.0f
#define USER_HEIGHT 16.0f
#define HORIZONTAL_PADDING 15.0f
#define TITLE_OFFSET 5.0f
#else
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:15.0f]
#define DESCRIPTION_FONT [UIFont fontWithName:IQ_HELVETICA size:13.0f]
#define TASK_ID_HEIGHT 11.0f
#define LABEL_FONT_SIZE 11.0f
#define USER_HEIGHT 13.0f
#define HORIZONTAL_PADDING 10.0f
#define TITLE_OFFSET 2.5f
#endif

@interface TInfoHeaderView() {
    UIEdgeInsets _headerInsets;
    BottomLineView * _buttonsHolder;
}

@end

@implementation TInfoHeaderView

+ (CGFloat)heightForText:(NSString*)text font:(UIFont*)font width:(CGFloat)textWidth {
    UITextView * titleTextView = [[UITextView alloc] init];
    [titleTextView setFont:font];
    titleTextView.textAlignment = NSTextAlignmentLeft;
    titleTextView.backgroundColor = [UIColor clearColor];
    titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    titleTextView.textContainerInset = UIEdgeInsetsZero;
    titleTextView.contentInset = UIEdgeInsetsZero;
    titleTextView.scrollEnabled = NO;
    titleTextView.text = text;
    [titleTextView sizeToFit];
    
    CGFloat textHeight = [titleTextView sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height;
    return textHeight;
}

+ (CGFloat)heightForTask:(IQTask*)task width:(CGFloat)width descriptionExpanded:(BOOL)descriptionExpanded {
    if (width <= 0) {
        return 0;
    }
    
    CGFloat hederWidth = width - CONTENT_LEFT_INSET - CONTENT_RIGHT_INSET;
    CGFloat height = HORIZONTAL_PADDING * 2 + TASK_ID_HEIGHT + TITLE_OFFSET + USER_OFFSET + USER_HEIGHT + LINE_HEIGHT + LINE_HEIGHT;
    
    CGSize titleLabelSize = [task.title sizeWithFont:TITLE_FONT
                                         constrainedToSize:CGSizeMake(hederWidth, CGFLOAT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
    
    height += titleLabelSize.height;
    
    if (task.parentTitle.length > 0) {
        NSString *baseTaskString = NSLocalizedString(@"Parent task:", nil);
        CGSize titleSize = [baseTaskString sizeWithFont:[UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE] constrainedToSize:CGSizeMake(hederWidth, CGFLOAT_MAX)];
        height += titleSize.height + USER_OFFSET;
        
        NSDictionary *attributes = nil;
        
        if (task.parentTaskAccess.boolValue) {
            attributes = @{NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                           NSUnderlineColorAttributeName  : IQ_BLUE_COLOR,
                           NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE],
                           NSForegroundColorAttributeName : IQ_BLUE_COLOR,
                           };
        }
        else {
            attributes = @{
                           NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE],
                           NSForegroundColorAttributeName : [UIColor blackColor],
                           };
        }
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:task.parentTitle attributes:attributes];
        CGRect parentTitleRect = [attributedString boundingRectWithSize:CGSizeMake(hederWidth, CGFLOAT_MAX) options:0 context:nil];
        height += parentTitleRect.size.height;
    }
    
    if (descriptionExpanded) {
        CGFloat descriptionHeight = [TInfoHeaderView heightForText:task.taskDescription
                                                              font:DESCRIPTION_FONT
                                                             width:hederWidth];

        height += LINE_HEIGHT + descriptionHeight + HORIZONTAL_PADDING;
    }
    else {
        height += LINE_HEIGHT;
    }
    
    if([task.community.title length] > 0) {
        height += LINE_HEIGHT;
    }
    
    if([task.project.title length] > 0) {
        height += LINE_HEIGHT;
    }
    
    if (task.reconciliation) {
        height += LINE_HEIGHT;
    }
    
    NSUInteger totalActions = [task.availableActions count] + [task.reconciliationActions count];
    if (totalActions > 0) {
#ifdef IPAD
        CGFloat buttonsInRow = roundf(hederWidth / (BUTTON_OFFSET + BUTTON_WIDTH));
        NSUInteger buttonRowsCount = ceil(totalActions / buttonsInRow);
        height += BUTTON_VERTICAL_PADDING * 2.0f + (BUTTON_OFFSET + BUTTON_HEIGHT) * buttonRowsCount - BUTTON_OFFSET;
#else
        height += BUTTON_VERTICAL_PADDING * 2.0f + (BUTTON_OFFSET + BUTTON_HEIGHT) * totalActions - BUTTON_OFFSET;
#endif
    }

    return height;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];

        _headerInsets = UIEdgeInsetsMake(HORIZONTAL_PADDING, CONTENT_LEFT_INSET, HORIZONTAL_PADDING, CONTENT_RIGHT_INSET);
        
        _taskIDLabel = [self makeLabelWithTextColor:IQ_FONT_GRAY_COLOR
                                               font:[UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE]
                                      localaizedKey:nil];
        _taskIDLabel.numberOfLines = 1;
        [self addSubview:_taskIDLabel];
        
        _titleLabel = [self makeLabelWithTextColor:IQ_BLACK_COLOR
                                              font:TITLE_FONT
                                     localaizedKey:nil];
        [self addSubview:_titleLabel];

        _fromLabel = [self makeLabelWithTextColor:IQ_FONT_GRAY_COLOR
                                             font:[UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE]
                                    localaizedKey:nil];
        _fromLabel.numberOfLines = 1;
        [self addSubview:_fromLabel];
        
        _toLabel = [self makeLabelWithTextColor:IQ_FONT_GRAY_COLOR
                                           font:[UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE]
                                  localaizedKey:nil];
        _toLabel.numberOfLines = 1;
        [self addSubview:_toLabel];
        
        _parentTaskLabel = [self makeLabelWithTextColor:IQ_FONT_GRAY_COLOR
                                                   font:[UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE]
                                          localaizedKey:@"Parent task:"];
        [self addSubview:_parentTaskLabel];
        
        _parentTaskButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:_parentTaskButton];
        
        _descriptionView = [[TInfoExpandableLineView alloc] init];
        _descriptionView.detailsTextLabel.font = DESCRIPTION_FONT;
        _descriptionView.backgroundColor = IQ_BACKGROUND_TASK_INFO_ROW_COLOR;
        _descriptionView.drawTopSeparator = YES;
        _descriptionView.textLabel.text = NSLocalizedString(@"Description", nil);
        [self addSubview:_descriptionView];

        _statusView = [[TInfoLineView alloc] init];
        _statusView.backgroundColor = IQ_BACKGROUND_TASK_INFO_ROW_COLOR;
        _statusView.drawTopSeparator = YES;
        [_statusView.imageView setImage:[UIImage imageNamed:@"task_status_ico.png"]];
        [self addSubview:_statusView];
        
        _dueDateView = [[TInfoLineView alloc] init];
        _dueDateView.backgroundColor = IQ_BACKGROUND_TASK_INFO_ROW_COLOR;
        [_dueDateView.imageView setImage:[UIImage imageNamed:@"bell_ico.png"]];
        _dueDateView.drawTopSeparator = YES;
        _dueDateView.drawLeftSeparator = YES;
        [self addSubview:_dueDateView];
        
        _projectInfoView = [[TInfoLineView alloc] init];
        _projectInfoView.backgroundColor = IQ_BACKGROUND_TASK_INFO_ROW_COLOR;
        [_projectInfoView.imageView setImage:[UIImage imageNamed:@"project_ico.png"]];
        [self addSubview:_projectInfoView];

        CGFloat icoSize = 17.0f;
        _communityInfoView = [[TInfoLineView alloc] init];
        _communityInfoView.backgroundColor = IQ_BACKGROUND_TASK_INFO_ROW_COLOR;
        _communityInfoView.imageViewSize = CGSizeMake(icoSize, icoSize);
        _communityInfoView.imageView.layer.cornerRadius = icoSize / 2.0f;
        _communityInfoView.imageView.clipsToBounds = YES;
        [_communityInfoView.imageView setImage:[UIImage imageNamed:@"community_ico.png"]];
        [self addSubview:_communityInfoView];
        
        _reconciliationInfoView = [[TInfoLineView alloc] init];
        _reconciliationInfoView.backgroundColor = IQ_BACKGROUND_TASK_INFO_ROW_COLOR;
        [_reconciliationInfoView.imageView setImage:[UIImage imageNamed:@"marker-check.png"]];
        [self addSubview:_reconciliationInfoView];
        
        _buttonsHolder = [[BottomLineView alloc] init];
        _buttonsHolder.bottomLineHeight = 0.5f;
        _buttonsHolder.bottomLineColor = IQ_SEPARATOR_LINE_COLOR;
        [_buttonsHolder setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_buttonsHolder];
        
        _complexityInfoView = [[TInfoLineView alloc] init];
        _complexityInfoView.backgroundColor = IQ_BACKGROUND_TASK_INFO_ROW_COLOR;
        _complexityInfoView.drawTopSeparator = YES;
        [_complexityInfoView.imageView setImage:[UIImage imageNamed:@"complexity_icon.png"]];
        [self addSubview:_complexityInfoView];
        
        _estimatedTimeInfoView = [[TInfoLineView alloc] init];
        _estimatedTimeInfoView.backgroundColor = IQ_BACKGROUND_TASK_INFO_ROW_COLOR;
        [_estimatedTimeInfoView.imageView setImage:[UIImage imageNamed:@"estimated_time_icon.png"]];
        _estimatedTimeInfoView.drawTopSeparator = YES;
        _estimatedTimeInfoView.drawLeftSeparator = YES;
        [self addSubview:_estimatedTimeInfoView];
    }
    
    return self;
}

- (void)setupByTask:(IQTask *)task {
    _taskIDLabel.text = (task.taskId) ? [NSString stringWithFormat:@"#%@", task.taskId] : @"";
    _titleLabel.text = task.title;
    _fromLabel.text = task.customer.displayName;
    _toLabel.text = ([task.executor.displayName length] > 0) ? [NSString stringWithFormat:@"> %@", task.executor.displayName] : @"";
    
    
    if (task.parentTitle.length > 0) {
        _parentTaskLabel.hidden = NO;
        
        NSDictionary *attributes = nil;
        
        if (task.parentTaskAccess.boolValue) {
            attributes = @{NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                           NSUnderlineColorAttributeName  : [UIColor blueColor],
                           NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE],
                           NSForegroundColorAttributeName : [UIColor blueColor],
                           };
        }
        else {
            attributes = @{
                           NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:LABEL_FONT_SIZE],
                           NSForegroundColorAttributeName : [UIColor blackColor],
                           };
        }
        
        _parentTaskButton.hidden = NO;
        [_parentTaskButton setAttributedTitle:[[NSAttributedString alloc] initWithString:task.parentTitle attributes:attributes] forState:UIControlStateNormal];
    }
    else {
        _parentTaskButton.hidden = YES;
        _parentTaskLabel.hidden = YES;
    }
    
    _descriptionView.enabled = ([task.taskDescription length] > 0);
    _descriptionView.detailsTextLabel.text = task.taskDescription;
    
    _statusView.textLabel.textColor = [TaskHelper colorForTaskType:task.status];
    _statusView.textLabel.text = NSLocalizedString(task.status, nil);

    _dueDateView.textLabel.text = [task.endDate dateToDayString];
    
    _complexityInfoView.textLabel.text = task.complexity.displayName;
    
    
    if (task.estimatedTime && task.estimatedTime.integerValue != 0) {
        NSMutableString *estimatedTimeString = [[NSMutableString alloc] init];

        NSUInteger seconds = task.estimatedTime.unsignedIntegerValue;
        
        NSUInteger hours = (NSUInteger)(seconds / 3600);
        NSUInteger minutes = (NSUInteger)((seconds - hours * 3600) / 60);
        
        if (hours < 10) {
            [estimatedTimeString appendString:@"0"];
        }
        [estimatedTimeString appendFormat:@"%lu", (unsigned long)hours];
        [estimatedTimeString appendString:@":"];

        if (minutes < 10) {
            [estimatedTimeString appendFormat:@"0"];
        }
        [estimatedTimeString appendFormat:@"%lu", (unsigned long)minutes];
        
        _estimatedTimeInfoView.textLabel.text = estimatedTimeString;
        _estimatedTimeInfoView.hidden = NO;
    }
    else {
        _estimatedTimeInfoView.hidden = YES;
    }
    

    
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.maximumLineHeight = [_communityInfoView.textLabel.font pointSize];
    paragraphStyle.minimumLineHeight = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.lineSpacing = 0.0f;
    
    NSDictionary * attributes = @{ NSForegroundColorAttributeName : _communityInfoView.textLabel.textColor,
                                   NSFontAttributeName            : _communityInfoView.textLabel.font ,
                                   NSParagraphStyleAttributeName  : paragraphStyle };
    

    _communityInfoView.hidden = ([task.community.title length] == 0);
    if([task.community.title length] > 0) {
        _communityInfoView.textLabel.attributedText = [[NSAttributedString alloc] initWithString:task.community.title
                                                                                      attributes:attributes];
    }
    
    _projectInfoView.hidden = ([task.project.title length] == 0);
    if([task.project.title length] > 0) {
        _projectInfoView.textLabel.attributedText = [[NSAttributedString alloc] initWithString:task.project.title
                                                                                    attributes:attributes];
    }
    
    if([task.community.thumbUrl length] > 0) {
        [_communityInfoView.imageView sd_setImageWithURL:[NSURL URLWithString:task.community.thumbUrl]
                                        placeholderImage:[UIImage imageNamed:@"community_ico.png"]];
    }
    else {
        _communityInfoView.imageView.image = [UIImage imageNamed:@"community_ico.png"];
    }
    
    if (task.reconciliation) {
        _reconciliationInfoView.textLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:
                                                                                                       NSLocalizedString(@"Task was reconciled by %@ in %@", nil),
                                                                                                       task.reconciliation.approvedCount,
                                                                                                       task.reconciliation.totalCount]
                                                                                           attributes:attributes];
    }
    
    
    NSMutableArray * actions = [[task.availableActions array] mutableCopy];
    [actions addObjectsFromArray:[task.reconciliationActions array]];
    
    for (NSInteger i = 0; i < [actions count]; i++) {
        NSString * actionType = actions[i];
        BOOL isPositiveAction = [TaskHelper isPositiveActionWithType:actionType];
        ExtendedButton * actionButton = [[ExtendedButton alloc] init];
        actionButton.layer.cornerRadius = 3.0f;
        if(!isPositiveAction) {
            actionButton.layer.borderWidth = 0.5f;
            actionButton.layer.borderColor = IQ_BUTTON_BORDER_COLOR.CGColor;
            [actionButton setTitleColor:IQ_BLUE_COLOR forState:UIControlStateNormal];
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
        
        [_buttonsHolder addSubview:actionButton];
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
                                           lineBreakMode:NSLineBreakByWordWrapping];
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
    
    if ([_parentTaskButton attributedTitleForState:UIControlStateNormal].length > 0) {
        CGSize labelSize = [_parentTaskLabel sizeThatFits:CGSizeMake(headerBounds.size.width, CGFLOAT_MAX)];
        _parentTaskLabel.frame = CGRectMake(headerBounds.origin.x,
                                            CGRectBottom(_fromLabel.frame) + USER_OFFSET,
                                            labelSize.width,
                                            labelSize.height);
        
        CGSize buttonSize = [_parentTaskButton sizeThatFits:CGSizeMake(headerBounds.size.width, CGFLOAT_MAX)];
        _parentTaskButton.frame = CGRectMake(headerBounds.origin.x ,
                                             CGRectBottom(_parentTaskLabel.frame),
                                             buttonSize.width,
                                             buttonSize.height);
    }
    else {
        _parentTaskLabel.frame = CGRectMake(headerBounds.origin.x,
                                            CGRectBottom(_fromLabel.frame),
                                            0.0f,
                                            0.0f);
        
        _parentTaskButton.frame = CGRectMake(headerBounds.origin.x ,
                                             CGRectBottom(_parentTaskLabel.frame),
                                             0.0f,
                                             0.0f);
    }
    
    if (_descriptionView.isExpanded) {
        CGFloat descriptionHight = [TInfoHeaderView heightForText:_descriptionView.detailsTextLabel.text
                                                             font:_descriptionView.detailsTextLabel.font
                                                            width:headerBounds.size.width];
        
        _descriptionView.frame = CGRectMake(bounds.origin.x,
                                            CGRectBottom(_parentTaskButton.frame) + _headerInsets.bottom,
                                            bounds.size.width,
                                            LINE_HEIGHT + descriptionHight + HORIZONTAL_PADDING);
    }
    else {
        _descriptionView.frame = CGRectMake(bounds.origin.x,
                                            CGRectBottom(_parentTaskButton.frame) + _headerInsets.bottom,
                                            bounds.size.width,
                                            LINE_HEIGHT);
    }

    
    CGSize halfWidhtLineSize = CGSizeMake(bounds.size.width / 2.0f, LINE_HEIGHT);
    
    _statusView.frame = CGRectMake(bounds.origin.x,
                                   CGRectBottom(_descriptionView.frame),
                                   halfWidhtLineSize.width,
                                   halfWidhtLineSize.height);
    
    _dueDateView.frame = CGRectMake(CGRectRight(_statusView.frame),
                                    _statusView.frame.origin.y,
                                    halfWidhtLineSize.width,
                                    halfWidhtLineSize.height);
    
    _complexityInfoView.frame = CGRectMake(bounds.origin.x,
                                           CGRectBottom(_statusView.frame),
                                           _estimatedTimeInfoView.hidden ? bounds.size.width : halfWidhtLineSize.width,
                                           halfWidhtLineSize.height);
    
    _estimatedTimeInfoView.frame = CGRectMake(CGRectRight(_complexityInfoView.frame),
                                              _complexityInfoView.frame.origin.y,
                                              halfWidhtLineSize.width,
                                              halfWidhtLineSize.height);

    if ([_projectInfoView.textLabel.text length] > 0) {
        _projectInfoView.frame = CGRectMake(bounds.origin.x,
                                            CGRectBottom(_complexityInfoView.frame),
                                            bounds.size.width,
                                            LINE_HEIGHT);
    }
    else {
        _projectInfoView.frame = CGRectMake(bounds.origin.x,
                                            CGRectBottom(_complexityInfoView.frame),
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
    
    if ([_reconciliationInfoView.textLabel.text length] > 0) {
        _reconciliationInfoView.frame = CGRectMake(bounds.origin.x,
                                              CGRectBottom(_communityInfoView.frame),
                                              bounds.size.width,
                                              LINE_HEIGHT);
    }
    else {
        _reconciliationInfoView.frame = CGRectMake(bounds.origin.x,
                                              CGRectBottom(_communityInfoView.frame),
                                              bounds.size.width,
                                              0.0f);
    }
    
    
    if([_buttonsHolder.subviews count] > 0) {
        NSUInteger buttonsCount = [_buttonsHolder.subviews count];
#ifdef IPAD
        CGFloat maxButtonsInRow = roundf(bounds.size.width / (BUTTON_OFFSET + BUTTON_WIDTH));
        NSUInteger buttonRowsCount = ceil(buttonsCount / maxButtonsInRow);
        NSUInteger buttonsInRow = MIN(maxButtonsInRow, buttonsCount);
        NSUInteger prevButtonRow = 0;
        CGFloat holderWidth = (BUTTON_OFFSET + BUTTON_WIDTH) * buttonsInRow;
        CGFloat firstButtonX = (BUTTON_OFFSET + bounds.size.width - holderWidth) / 2.0f;
        CGFloat buttonX = firstButtonX;
 
        CGFloat buttonsHolderHeight = BUTTON_VERTICAL_PADDING * 2.0f + (BUTTON_OFFSET + BUTTON_HEIGHT) * buttonRowsCount - BUTTON_OFFSET;
        CGRect buttonsHolderRect = CGRectMake(bounds.origin.x,
                                              CGRectBottom(_communityInfoView.frame),
                                              bounds.size.width,
                                              buttonsHolderHeight);
#else
        CGFloat buttonY = BUTTON_VERTICAL_PADDING;
        CGFloat buttonsHolderHeight = BUTTON_VERTICAL_PADDING * 2.0f + (BUTTON_OFFSET + BUTTON_HEIGHT) * [[_buttonsHolder subviews] count] - BUTTON_OFFSET;
        CGRect buttonsHolderRect = CGRectMake(bounds.origin.x,
                                              CGRectBottom(_reconciliationInfoView.frame),
                                              bounds.size.width,
                                              buttonsHolderHeight);
#endif

        _buttonsHolder.frame = buttonsHolderRect;
        
        for (NSUInteger index = 0; index < buttonsCount; index++) {
            UIView * view = _buttonsHolder.subviews[index];
#ifdef IPAD
            NSUInteger buttonRow = floor(index / buttonsInRow);
            if (prevButtonRow != buttonRow) {
                buttonX = firstButtonX;
                prevButtonRow = buttonsInRow;
            }
            
            view.frame = CGRectMake(buttonX,
                                    BUTTON_VERTICAL_PADDING + (BUTTON_HEIGHT + BUTTON_OFFSET) * buttonRow,
                                    BUTTON_WIDTH,
                                    BUTTON_HEIGHT);
            buttonX = CGRectRight(view.frame) + BUTTON_OFFSET;
#else
            view.frame = CGRectMake(BUTTON_OFFSET,
                                    buttonY,
                                    _buttonsHolder.frame.size.width - BUTTON_OFFSET * 2,
                                    BUTTON_HEIGHT);
            buttonY = CGRectBottom(view.frame) + BUTTON_OFFSET;
#endif
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
