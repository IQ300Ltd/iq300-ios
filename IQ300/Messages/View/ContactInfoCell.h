//
//  ContactInfoCell.h
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "SWTableViewCell.h"
#import "IQTableCell.h"

@class IQConversationMember;

@interface ContactInfoCell : SWTableViewCell<IQTableCell>

@property (nonatomic, strong) IQConversationMember * item;

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

- (void)setDeleteEnabled:(BOOL)enabled;

@end
