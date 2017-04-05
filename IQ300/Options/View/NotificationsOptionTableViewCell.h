//
//  NotificationsOptionTableViewCell.h
//  IQ300
//
//  Created by Viktor Shabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTableCell.h"
#import "NotificationsOptionItem.h"

@interface NotificationsOptionTableViewCell : UITableViewCell <IQTableCell>

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UISwitch *notificationsSwitch;

@property (nonatomic, strong) NotificationsOptionItem *item;

@end
