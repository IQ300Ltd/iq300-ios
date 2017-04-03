//
//  OptionsModel.h
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"
#import "NotificationsOptionTableViewCell.h"
#import "IQService+Settings.h"

@interface OptionsModel : IQTableModel

@property (nonatomic, assign) BOOL enableInteraction;
@property (nonatomic, assign) BOOL notificationsEnabeld;

@end
