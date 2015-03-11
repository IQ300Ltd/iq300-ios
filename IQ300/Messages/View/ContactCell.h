//
//  ContactCell.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQUser;

@interface ContactCell : UITableViewCell

@property (nonatomic, strong) IQUser * item;

@end
