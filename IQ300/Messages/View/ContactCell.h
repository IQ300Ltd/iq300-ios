//
//  ContactCell.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQSelectableTextCell.h"

@class IQContact;
@class IQOnlineIndicator;

@interface ContactCell : IQSelectableTextCell

@property (nonatomic, strong) IQContact * item;
@property (nonatomic, strong) IQOnlineIndicator *onlineIndicator;


@end
