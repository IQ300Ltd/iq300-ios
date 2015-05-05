//
//  TAttachmentCell.h
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQAttachment;

@interface TAttachmentCell : UITableViewCell {
    UIEdgeInsets _contentBackgroundInsets;
}

@property (nonatomic, strong) IQAttachment * item;
@property (nonatomic, readonly) UIView * contentBackgroundView;

@end
