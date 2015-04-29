//
//  SubMenuCell.m
//  IQ300
//
//  Created by Tayphoon on 29.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "SubMenuCell.h"

@implementation SubMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        _contentInsets = UIEdgeInsetsMake(0, CONTENT_LEFT_INSET * 2, 0, CONTENT_RIGHT_INSET);
    }
    return self;
}

@end
