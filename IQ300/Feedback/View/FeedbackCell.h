//
//  FeedbackCell.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQManagedFeedback;

@interface FeedbackCell : UITableViewCell

@property (nonatomic, strong) IQManagedFeedback * item;

+ (CGFloat)heightForItem:(IQManagedFeedback *)item andCellWidth:(CGFloat)cellWidth;

@end
