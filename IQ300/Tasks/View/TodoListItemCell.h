//
//  CheckListItemCell.h
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQTodoItem;

@interface TodoListItemCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
    UIImageView * _accessoryImageView;
}

@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, strong) IQTodoItem * item;

+ (CGFloat)heightForItem:(IQTodoItem *)item width:(CGFloat)width;

@end
