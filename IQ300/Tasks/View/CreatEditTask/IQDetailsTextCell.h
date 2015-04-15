//
//  IQDetailsTextCell.h
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQEditableTextCell.h"

@interface IQDetailsTextCell : IQEditableTextCell {
    UIImageView * _accessoryImageView;
}

@property (nonatomic, strong) UIImage * accessoryImage;

@end
