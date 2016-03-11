//
//  TaskEstimatedTimeCell.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQItemCellProtocol.h"
#import "IQTextCell.h"

@protocol IQEstimatedTimeCellDelegate;


@interface IQEstimatedTimeCell : UITableViewCell<IQItemCellProtocol>

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UILabel *commaLabel;
@property (nonatomic, strong) UITextField *hoursTextField;
@property (nonatomic, strong) UITextField *minutesTextField;
@property (nonatomic, weak) id <IQEstimatedTimeCellDelegate> delegate;

+ (CGFloat)heightForItem:(IQItem *)item width:(CGFloat)width;

- (void)setItem:(IQItem *)item;
- (CGFloat)heightForWidth:(CGFloat)width;

@end

@protocol IQEstimatedTimeCellDelegate <NSObject>

@optional
- (BOOL)estimatedTimeCell:(IQEstimatedTimeCell *)cell textFieldShouldBeginEditing:(UITextField *)textField;
- (void)estimatedTimeCell:(IQEstimatedTimeCell *)cell textFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)estimatedTimeCell:(IQEstimatedTimeCell *)cell textFieldShouldEndEditing:(UITextField *)textField;
- (void)estimatedTimeCell:(IQEstimatedTimeCell *)cell textFieldDidEndEditing:(UITextField *)textField;

- (BOOL)estimatedTimeCell:(IQEstimatedTimeCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)estimatedTimeCell:(IQEstimatedTimeCell *)cell textFieldShouldClear:(UITextField *)textField;
- (BOOL)estimatedTimeCell:(IQEstimatedTimeCell *)cell textFieldShouldReturn:(UITextField *)textField;

@end