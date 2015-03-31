//
//  TMemberCell.m
//  IQ300
//
//  Created by Tayphoon on 25.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import "TMemberCell.h"
#import "IQTaskMember.h"
#import "IQUser.h"

#define SELECTED_BBACKGROUND_COLOR [UIColor colorWithHexInt:0x2e4865]
#define TEXT_COLOR [UIColor colorWithHexInt:0x2c74a4]
#define SELECTED_TEXT_COLOR [UIColor whiteColor]

@interface TMemberCell() {
    UIView * _selectedBackgroundView;
}

@end

@implementation TMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        _selectedBackgroundView = [[UIView alloc] init];
        [_selectedBackgroundView setBackgroundColor:SELECTED_BBACKGROUND_COLOR];
        [self setSelectedBackgroundView:_selectedBackgroundView];
        
        self.textLabel.font = [UIFont fontWithName:IQ_HELVETICA size:15];
        self.textLabel.textColor = TEXT_COLOR;
        
        self.detailTextLabel.font = [UIFont fontWithName:IQ_HELVETICA size:12];
        self.detailTextLabel.textColor = [UIColor colorWithHexInt:0x8e8d8e];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.textLabel.textColor = (selected) ? SELECTED_TEXT_COLOR : TEXT_COLOR;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.textLabel.textColor = (highlighted) ? SELECTED_TEXT_COLOR : TEXT_COLOR;
}

- (void)setItem:(IQTaskMember *)item {
    _item = item;
    
    self.textLabel.text = _item.user.displayName;
    self.detailTextLabel.numberOfLines = 0;
    
    UIFont * font = [UIFont fontWithName:IQ_HELVETICA size:13];
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.maximumLineHeight = 1000;
    paragraphStyle.minimumLineHeight = 3;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.lineSpacing = 3.0f;
    
    NSMutableDictionary * attributes = @{
                                         NSParagraphStyleAttributeName  : paragraphStyle,
                                         NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x9f9f9f],
                                         NSFontAttributeName            : font
                                         }.mutableCopy ;
    
    NSMutableAttributedString * detailText = [[NSMutableAttributedString alloc] init];
    
    if ([_item.user.email length] > 0) {
        NSAttributedString * emailString = [[NSAttributedString alloc] initWithString:_item.user.email
                                                                           attributes:attributes];
        [detailText appendAttributedString:emailString];
    }
    
    if([_item.taskRoleName length] > 0) {
        [attributes setValue:[UIFont fontWithName:IQ_HELVETICA size:10] forKey:NSFontAttributeName];
        
        NSAttributedString * taskRoleName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", item.taskRoleName]
                                                                            attributes:attributes];
        [detailText appendAttributedString:taskRoleName];
    }
    self.detailTextLabel.attributedText = detailText;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self hideUtilityButtonsAnimated:NO];
}

- (void)setAvailableActions:(NSArray *)availableActions {
    _availableActions = availableActions;
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray array];
    if ([_availableActions containsObject:@"destroy"] ||
        [_availableActions containsObject:@"leave"]) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexInt:0x3b5b78]
                                                     icon:[UIImage imageNamed:@"delete_ico"]];
    }
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:68.0f];
}

@end
