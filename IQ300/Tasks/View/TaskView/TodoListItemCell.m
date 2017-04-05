//
//  TodoListItemCell.m
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TodoListItemCell.h"
#import "TodoItem.h"

#define TEXT_COLOR IQ_FONT_BLACK_COLOR
#define SELECTED_TEXT_COLOR IQ_FONT_GRAY_COLOR
#define CONTENT_VERTICAL_INSETS 12
#define CONTENT_HORIZONTAL_INSETS 13
#define ACCESSORY_VIEW_SIZE 20.0f
#define TITLE_OFFSET 10.0f

#ifdef IPAD
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:14]
#else
#define TITLE_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#endif

@interface TodoListItemCell() {
    BOOL _isChecked;
}

@end

@implementation TodoListItemCell

+ (CGFloat)heightForItem:(id<TodoItem>)item width:(CGFloat)width {
    CGFloat cellWidth = width - CONTENT_HORIZONTAL_INSETS * 2.0f;
    CGFloat textWidth = cellWidth - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
    CGFloat height = CONTENT_VERTICAL_INSETS * 2.0f;
    
    UITextView * titleTextView = [[UITextView alloc] init];
    [titleTextView setFont:TITLE_FONT];
    titleTextView.textAlignment = NSTextAlignmentLeft;
    titleTextView.backgroundColor = [UIColor clearColor];
    titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    titleTextView.textContainerInset = UIEdgeInsetsZero;
    titleTextView.contentInset = UIEdgeInsetsZero;
    titleTextView.scrollEnabled = NO;
    titleTextView.text = item.title;
    [titleTextView sizeToFit];
    
    CGFloat titleHeight = [titleTextView sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height;
    height += titleHeight;
    
    return MAX(height, 50.0f);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.backgroundColor = IQ_GRAY_LIGHT_COLOR;
        
        _enabled = YES;
        _contentInsets = UIEdgeInsetsMake(CONTENT_VERTICAL_INSETS, CONTENT_HORIZONTAL_INSETS, CONTENT_VERTICAL_INSETS, CONTENT_HORIZONTAL_INSETS);
        _accessoryImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_accessoryImageView];
        
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        _titleTextView = [[UITextView alloc] init];
        [_titleTextView setFont:TITLE_FONT];
        [_titleTextView setTextColor:TEXT_COLOR];
        _titleTextView.textAlignment = NSTextAlignmentLeft;
        _titleTextView.backgroundColor = [UIColor clearColor];
        _titleTextView.editable = NO;
        _titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _titleTextView.textContainerInset = UIEdgeInsetsZero;
        _titleTextView.contentInset = UIEdgeInsetsZero;
        _titleTextView.scrollEnabled = NO;
        _titleTextView.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:_titleTextView];
        
        _isChecked = NO;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGSize accessorySize = CGSizeMake(ACCESSORY_VIEW_SIZE, ACCESSORY_VIEW_SIZE);
    _accessoryImageView.frame = CGRectMake(actualBounds.origin.x,
                                           actualBounds.origin.y + (actualBounds.size.height - accessorySize.height) / 2.0f,
                                           accessorySize.width,
                                           accessorySize.height);
    
    
    CGFloat titleWidth = actualBounds.size.width - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;

    CGFloat titleHeight = [_titleTextView sizeThatFits:CGSizeMake(titleWidth, CGFLOAT_MAX)].height;

    _titleTextView.frame = CGRectMake(CGRectRight(_accessoryImageView.frame) + TITLE_OFFSET,
                                      actualBounds.origin.y + (actualBounds.size.height - titleHeight) / 2.0f,
                                      titleWidth,
                                      titleHeight);
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    //[super setAccessoryType:accessoryType];
    
    _isChecked = (accessoryType == UITableViewCellAccessoryCheckmark);
    
    if (accessoryType == UITableViewCellAccessoryCheckmark) {
        _accessoryImageView.image = [UIImage imageNamed:@"gray_checked_checkbox.png"];
    }
    else {
        _accessoryImageView.image = [UIImage imageNamed:@"gray_checkbox.png"];
    }
    
    [self updateText];
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        [self updateText];
    }
}

- (void)setItem:(id<TodoItem>)item {
    _item = item;
   [self updateText];
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle {
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _isChecked = NO;
    _enabled = YES;
    _titleTextView.editable = NO;
    _titleTextView.text = nil;

    [self updateText];
    [self setDelegate:nil];
    [self hideUtilityButtonsAnimated:NO];
    [self setRightUtilityButtons:nil];
}

- (void)setAvailableActions:(NSArray *)availableActions {
    _availableActions = availableActions;
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray array];
    if ([_availableActions containsObject:@"edit"]) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:IQ_BACKGROUND_P1_COLOR
                                                     icon:[UIImage imageNamed:@"edit_white_ico.png"]];
        
        if ([availableActions count] > 1) {
            UIView * parentView = [rightUtilityButtons objectAtIndex:0];
            [self addRightSeparatorView:parentView];
        }
    }
    
    if ([_availableActions containsObject:@"delete"]) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:IQ_BACKGROUND_P1_COLOR
                                                     icon:[UIImage imageNamed:@"delete_ico.png"]];
    }
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:68.0f];
}

- (void)addRightSeparatorView:(UIView*)parentView {
    CGFloat separatorHeight = 0.5f;
    UIView * separatorView = [[UIView alloc] initWithFrame:CGRectMake(parentView.frame.size.width - separatorHeight, 0.0f, separatorHeight, 0.0f)];
    separatorView.backgroundColor = [UIColor colorWithHexInt:0xc0c0c0];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [parentView addSubview:separatorView];
}

- (void)updateText {
    NSString * title = ([_item.title length] > 0) ? _item.title : @"";
    UIColor * curColor = (_isChecked || !_enabled) ? SELECTED_TEXT_COLOR : TEXT_COLOR;
    
    NSMutableDictionary * attributes = @{
                                         NSFontAttributeName                : TITLE_FONT,
                                         NSForegroundColorAttributeName     : curColor
                                         }.mutableCopy;
    if(_isChecked) {
        [attributes setValue:@(NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName];
        [attributes setValue:curColor forKey:NSStrikethroughColorAttributeName];
    }
    
    _titleTextView.attributedText = [[NSAttributedString alloc] initWithString:title
                                                                    attributes:attributes];
}

@end
