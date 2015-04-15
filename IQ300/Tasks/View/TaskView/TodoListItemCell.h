//
//  TodoListItemCell.h
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

@protocol TodoItem;

@interface TodoListItemCell : SWTableViewCell {
    UIEdgeInsets _contentInsets;
    UIImageView * _accessoryImageView;
}

@property (nonatomic, readonly) UITextView * titleTextView;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, strong) id<TodoItem> item;
@property (nonatomic, strong) NSArray * availableActions;

+ (CGFloat)heightForItem:(id<TodoItem>)item width:(CGFloat)width;

@end
