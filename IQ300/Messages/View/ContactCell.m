//
//  ContactCell.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "ContactCell.h"
#import "IQUser.h"

#define SELECTED_BBACKGROUND_COLOR [UIColor colorWithHexInt:0x2e4865]
#define TEXT_COLOR [UIColor colorWithHexInt:0x2c74a4]
#define SELECTED_TEXT_COLOR [UIColor whiteColor]

@interface ContactCell() {
    UIView * _selectedBackgroundView;
}

@end

@implementation ContactCell

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

- (void)setItem:(IQUser *)item {
    _item = item;
    
    self.textLabel.text = _item.displayName;
    self.detailTextLabel.text = _item.email;
}

@end
