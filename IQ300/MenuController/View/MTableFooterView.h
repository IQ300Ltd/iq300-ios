//
//  MTableFooterView.h
//  IQ300
//
//  Created by Tayphoon on 24.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTableFooterView : UIView {
    UIEdgeInsets _contentInsets;
    void (^_actionBlock)(MTableFooterView * footerView);
}

@property (nonatomic, assign) CGFloat topLineHeight;
@property (nonatomic , strong) UIColor * topLineColor;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign, getter=isSelectable) BOOL selectable;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (void)setActionBlock:(void (^)(MTableFooterView * footerView))block;

@end
