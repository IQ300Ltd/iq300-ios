//
//  ContactsSectionView.h
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@interface ContactsSectionView : BottomLineView {
    UIEdgeInsets _contentInsets;    
}

@property (nonatomic, strong) NSString * title;

@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UIView * leftView;

+ (CGFloat)heightForTitle:(NSString*)title width:(CGFloat)cellWidth;

@end
