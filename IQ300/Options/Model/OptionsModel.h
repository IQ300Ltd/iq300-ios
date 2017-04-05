//
//  OptionsModel.h
//  IQ300
//
//  Created by Viktor Shabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"
#import "NotificationsOptionTableViewCell.h"
#import "IQService+Settings.h"

@interface OptionsModel : IQTableModel

- (void)updateModelWithInteractionEnable:(BOOL)enable
                              completion:(void (^)(BOOL success, BOOL granted, NSError * error))completion;

@end
