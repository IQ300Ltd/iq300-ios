//
//  AttachmentsView.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 09/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQAttachment;

@interface IQAttachmentsView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) NSArray *attachmentButtons;

- (void)setItems:(NSArray<__kindof IQAttachment *> *)items isMine:(BOOL)isMine;
- (BOOL)hasAttachments;

@end