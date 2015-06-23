//
//  IQDoubleDetailsTextCell.m
//  IQ300
//
//  Created by Tayphoon on 19.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQDoubleDetailsTextCell.h"

#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xc0c0c0]
#define TEXT_COLOR [UIColor colorWithHexInt:0x272727]
#define CONTENT_VERTICAL_INSETS 12
#define CONTENT_HORIZONTAL_INSETS 13
#define CELL_MIN_HEIGHT 50.0f
#define CELL_MAX_HEIGHT 71.5f
#define ACCESSORY_VIEW_SIZE 17.0f
#define TITLE_OFFSET 10.0f

#ifdef IPAD
#define TEXT_FONT [UIFont fontWithName:IQ_HELVETICA size:14]
#else
#define TEXT_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#endif

#define SELECTED_TEXT_COLOR [UIColor colorWithHexInt:0x9f9f9f]

@interface IQDoubleDetailsTextCell() {
    UIView * _separatorView;
    UIView * _firstContentView;
    UIView * _secondContentView;
}

@end

@implementation IQDoubleDetailsTextCell

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * text = ([item isKindOfClass:[NSString class]]) ? item : detailTitle;
    CGFloat cellWidth = width / 2.0f - CONTENT_HORIZONTAL_INSETS * 2.0f;
    CGFloat textWidth = cellWidth - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
    CGFloat height = CONTENT_VERTICAL_INSETS * 2.0f;
    
    UITextView * titleTextView = [[UITextView alloc] init];
    [titleTextView setFont:TEXT_FONT];
    titleTextView.textAlignment = NSTextAlignmentLeft;
    titleTextView.backgroundColor = [UIColor clearColor];
    titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    titleTextView.textContainerInset = UIEdgeInsetsZero;
    titleTextView.contentInset = UIEdgeInsetsZero;
    titleTextView.scrollEnabled = NO;
    titleTextView.text = text;
    [titleTextView sizeToFit];
    
    CGFloat titleHeight = [titleTextView sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height;
    height += titleHeight;
    
    return MIN(MAX(height, CELL_MIN_HEIGHT), CELL_MAX_HEIGHT);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        _enabled = YES;
        _secondEnabled = YES;
        _contentInsets = UIEdgeInsetsMake(CONTENT_VERTICAL_INSETS,
                                          CONTENT_HORIZONTAL_INSETS,
                                          CONTENT_VERTICAL_INSETS,
                                          CONTENT_HORIZONTAL_INSETS);
        
        self.backgroundColor = [UIColor whiteColor];
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        UITapGestureRecognizer * firstTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(firstTapRecognized:)];
        firstTapGesture.numberOfTapsRequired = 1;
        _firstContentView = [[UIView alloc] init];
        _firstContentView.backgroundColor = [UIColor clearColor];
        [_firstContentView addGestureRecognizer:firstTapGesture];
        [self.contentView addSubview:_firstContentView];
        
        UITapGestureRecognizer * secondTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(secondTapRecognized:)];
        secondTapGesture.numberOfTapsRequired = 1;
        _secondContentView = [[UIView alloc] init];
        _secondContentView.backgroundColor = [UIColor clearColor];
        [_secondContentView addGestureRecognizer:secondTapGesture];
        [self.contentView addSubview:_secondContentView];

        _titleTextView = [[PlaceholderTextView alloc] init];
        [_titleTextView setFont:TEXT_FONT];
        [_titleTextView setTextColor:TEXT_COLOR];
        _titleTextView.userInteractionEnabled = NO;
        _titleTextView.editable = NO;
        _titleTextView.textContainer.maximumNumberOfLines = 3;
        _titleTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleTextView.textAlignment = NSTextAlignmentLeft;
        _titleTextView.backgroundColor = [UIColor clearColor];
        _titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _titleTextView.textContainerInset = UIEdgeInsetsZero;
        _titleTextView.contentInset = UIEdgeInsetsZero;
        _titleTextView.scrollEnabled = NO;
        _titleTextView.returnKeyType = UIReturnKeyDone;
        _titleTextView.placeholderInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
        [self.contentView addSubview:_titleTextView];
        
        _accessoryImageView = [[UIImageView alloc] init];
        _accessoryImageView.contentMode = UIViewContentModeCenter;
        _accessoryImageView.image = [UIImage imageNamed:@"right_gray_arrow.png"];
        [self.contentView addSubview:_accessoryImageView];
        
        _secondTitleTextView = [[PlaceholderTextView alloc] init];
        [_secondTitleTextView setFont:TEXT_FONT];
        [_secondTitleTextView setTextColor:TEXT_COLOR];
        _secondTitleTextView.userInteractionEnabled = NO;
        _secondTitleTextView.editable = NO;
        _secondTitleTextView.textContainer.maximumNumberOfLines = 3;
        _secondTitleTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        _secondTitleTextView.textAlignment = NSTextAlignmentLeft;
        _secondTitleTextView.backgroundColor = [UIColor clearColor];
        _secondTitleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _secondTitleTextView.textContainerInset = UIEdgeInsetsZero;
        _secondTitleTextView.contentInset = UIEdgeInsetsZero;
        _secondTitleTextView.scrollEnabled = NO;
        _secondTitleTextView.returnKeyType = UIReturnKeyDone;
        _secondTitleTextView.placeholderInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
        [self.contentView addSubview:_secondTitleTextView];
        
        _secondAccessoryImageView = [[UIImageView alloc] init];
        _secondAccessoryImageView.contentMode = UIViewContentModeCenter;
        _secondAccessoryImageView.image = [UIImage imageNamed:@"right_gray_arrow.png"];
        [self.contentView addSubview:_secondAccessoryImageView];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = SEPARATOR_COLOR;
        [self.contentView addSubview:_separatorView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGFloat viewsWidth = actualBounds.size.width / 2.0f;
    _firstContentView.frame = CGRectMake(bounds.origin.x,
                                         bounds.origin.y,
                                         bounds.size.width / 2.0f,
                                         bounds.size.height);
    
    CGSize accessorySize = CGSizeMake(ACCESSORY_VIEW_SIZE, ACCESSORY_VIEW_SIZE);
    _accessoryImageView.frame = CGRectMake(actualBounds.origin.x + viewsWidth - accessorySize.width - CONTENT_HORIZONTAL_INSETS,
                                           actualBounds.origin.y + (actualBounds.size.height - accessorySize.height) / 2.0f,
                                           accessorySize.width,
                                           accessorySize.height);

    CGFloat titleWidth = viewsWidth - ACCESSORY_VIEW_SIZE - TITLE_OFFSET - CONTENT_HORIZONTAL_INSETS;
    CGFloat titleHeight = [_titleTextView sizeThatFits:CGSizeMake(viewsWidth, CGFLOAT_MAX)].height;
    CGFloat secondTitleHeight = [_secondTitleTextView sizeThatFits:CGSizeMake(viewsWidth, CGFLOAT_MAX)].height;
    CGFloat titlesHeight = MAX(titleHeight, secondTitleHeight);

    _titleTextView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y + (actualBounds.size.height - titlesHeight) / 2.0f,
                                      titleWidth,
                                      titlesHeight);
    
    _secondContentView.frame = CGRectMake(bounds.origin.x + _firstContentView.frame.size.width + 0.5f,
                                          bounds.origin.y,
                                          _firstContentView.frame.size.width,
                                          bounds.size.height);

    _secondAccessoryImageView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - accessorySize.width,
                                                 actualBounds.origin.y + (actualBounds.size.height - accessorySize.height) / 2.0f,
                                                 accessorySize.width,
                                                 accessorySize.height);

    _secondTitleTextView.frame = CGRectMake(actualBounds.origin.x + viewsWidth + CONTENT_HORIZONTAL_INSETS,
                                            actualBounds.origin.y + (actualBounds.size.height - secondTitleHeight) / 2.0f,
                                            titleWidth,
                                            secondTitleHeight);
    
    _separatorView.frame = CGRectMake(bounds.size.width / 2.0f,
                                      bounds.origin.y,
                                      0.5f,
                                      bounds.size.height);
}

- (void)setItem:(NSArray*)item {
    _item = item;
    
    if ([_item count] > 2 && [_item[0] isKindOfClass:[NSString class]] &&
        [_item[1] isKindOfClass:[NSString class]]) {
        _titleTextView.text = _item[0];
        _secondTitleTextView.text = _item[1];
    }
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        _titleTextView.textColor = (_enabled) ? TEXT_COLOR : SELECTED_TEXT_COLOR;
        _accessoryImageView.image = (_enabled) ? [UIImage imageNamed:@"right_gray_arrow.png"] : nil;
    }
}

- (void)setSecondEnabled:(BOOL)secondEnabled {
    if (_secondEnabled != secondEnabled) {
        _secondEnabled = secondEnabled;
        _secondTitleTextView.textColor = (_secondEnabled) ? TEXT_COLOR : SELECTED_TEXT_COLOR;
        _secondAccessoryImageView.image = (_secondEnabled) ? [UIImage imageNamed:@"right_gray_arrow.png"] : nil;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _enabled = YES;
    _secondEnabled = YES;
    _titleTextView.text = nil;
    _titleTextView.placeholder = nil;
    _titleTextView.textColor = TEXT_COLOR;
    _secondTitleTextView.text = nil;
    _secondTitleTextView.placeholder = nil;
    _secondTitleTextView.textColor = TEXT_COLOR;
}

#pragma mark - Pivate methods

- (void)firstTapRecognized:(UITapGestureRecognizer*)gesture {
    UITableView * parentTableView = [self parentTableView];
    if (self.isEnabled && parentTableView &&
        [parentTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        NSIndexPath * indexPath = [parentTableView indexPathForCell:self];
        [parentTableView.delegate tableView:parentTableView
                    didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.tag
                                                               inSection:indexPath.section]];
    }
}

- (void)secondTapRecognized:(UITapGestureRecognizer*)gesture {
    UITableView * parentTableView = [self parentTableView];
    if (self.isSecondEnabled && parentTableView &&
        [parentTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        NSIndexPath * indexPath = [parentTableView indexPathForCell:self];
        [parentTableView.delegate tableView:parentTableView
                    didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.tag + 1
                                                               inSection:indexPath.section]];
    }
}

- (UITableView *)parentTableView {
    UITableView *tableView = nil;
    UIView *view = self;
    while(view != nil) {
        if([view isKindOfClass:[UITableView class]]) {
            tableView = (UITableView *)view;
            break;
        }
        view = [view superview];
    }
    return tableView;
}

@end
