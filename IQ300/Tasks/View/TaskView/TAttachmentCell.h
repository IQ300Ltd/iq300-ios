//
//  TAttachmentCell.h
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQManagedAttachment;

@interface TAttachmentCell : UICollectionViewCell

@property (nonatomic, strong) IQManagedAttachment *item;

@end