//
//  ExecutersGroupSection.h
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@interface ExecutersGroupSection : BottomLineView {
    void (^_actionBlock)(ExecutersGroupSection * header);
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UIView * leftView;
@property (nonatomic, readonly) UIImageView * accessoryImageView;

@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, assign, getter=isLeftViewShown) BOOL showLeftView;

+ (CGFloat)heightForTitle:(NSString*)title width:(CGFloat)cellWidth;

- (void)setActionBlock:(void (^)(ExecutersGroupSection * header))block;

@end
