//
//  TaskEstimatedTimeCell.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTableCell.h"

@interface TaskEstimatedTimeCell : UITableViewCell<IQTableCell>

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UILabel *commaLabel;
@property (nonatomic, strong) UITextField *hoursTextField;
@property (nonatomic, strong) UITextField *minutesTextField;

@property (nonatomic, strong) NSNumber *item;

@end
