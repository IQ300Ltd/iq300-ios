//
//  IQSelectableTextCell.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQSelectableTextCell.h"

@implementation IQSelectableTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        _accessoryImageView.image = nil;
    }
    
    return self;
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    if (accessoryType == UITableViewCellAccessoryCheckmark) {
        _accessoryImageView.image = [UIImage imageNamed:@"filterSelected.png"];
        self.titleTextView.textColor = SELECTED_TEXT_COLOR;
    } else {
        _accessoryImageView.image = nil;
        self.titleTextView.textColor = TEXT_COLOR;
    }
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle {
    
}

@end
