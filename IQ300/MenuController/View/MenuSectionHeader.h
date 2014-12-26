//
//  MenuSectionHeader.h
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@class IQBadgeView;

@interface MenuSectionHeader : BottomLineView {
    void (^_actionBlock)(MenuSectionHeader* header);
}

@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) NSString * badgeText;

@property (nonatomic, readonly) IQBadgeView * badgeView;

@property (nonatomic, assign, getter=isSelectable) BOOL selectable;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

- (void)setActionBlock:(void (^)(MenuSectionHeader* header))block;
- (void)setExpandable:(BOOL)expandable;

@end
