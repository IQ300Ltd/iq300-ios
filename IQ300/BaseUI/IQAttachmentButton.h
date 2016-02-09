//
//  AttachmentView.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 09/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQAttachment;

@interface IQAttachmentButton : UIButton

@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic, strong) UILabel *label;

- (void)setItem:(IQAttachment *)attachment isMine:(BOOL)isMine;

@end
