//
//  CheckListSectionView.h
//  IQ300
//
//  Created by Tayphoon on 19.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@interface TodoListSectionView : BottomLineView {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UIButton * editButton;

@end
