//
//  FeedbackAttachmentsCell.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 02/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQAttachment.h"
#import "IQAttachmentButton.h"
#import "IQAttachmentAddButton.h"

@interface FeedbackAttachmentsCell : UITableViewCell

@property (nonatomic, strong, readonly) NSArray <__kindof IQAttachmentButton*> *buttons;

@property (nonatomic, strong, readonly) UIView *titleView;

@property (nonatomic, strong, readonly) UIButton *addButton;
@property (nonatomic, strong, readonly) UILabel *label;

@property (nonatomic, strong) NSArray <__kindof id<IQAttachment>> *items;

@property (nonatomic, assign) BOOL addButtonShown;

+ (CGFloat)heightForItems:(NSArray<__kindof id<IQAttachment>> *)items cellWidth:(CGFloat)cellWidth showAddButton:(BOOL)show;

@end
