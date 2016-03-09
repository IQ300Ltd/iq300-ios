//
//  AttachmentView.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 09/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQAttachment.h"

@interface IQAttachmentButton : UIButton

@property (nonatomic, strong) UIView *roundRectContainer;
@property (nonatomic, strong, readonly) UIImageView *customImageView;
@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong, readonly) UIButton *deleteButton;

@property (nonatomic, strong) UIColor *defaultColor;
@property (nonatomic, strong) UIColor *mineColor;

@property (nonatomic, assign) BOOL deleteButtonShown;

- (void)setItem:(id<IQAttachment>)attachment isMine:(BOOL)isMine;
- (void)setItem:(id<IQAttachment>)attachment isMine:(BOOL)isMine showDeleteButton:(BOOL)show;

@end
