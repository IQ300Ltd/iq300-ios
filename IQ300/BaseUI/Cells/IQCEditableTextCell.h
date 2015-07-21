//
//  IQCEditableTextCell.h
//  IQ300
//
//  Created by Tayphoon on 21.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQEditableTextCell.h"

@interface IQCEditableTextCell : IQEditableTextCell

@property (nonatomic, readonly) UIButton * clearTextViewButton;
@property (nonatomic, getter = isClearButtonEnabled) BOOL clearButtonEnabled;

@end
