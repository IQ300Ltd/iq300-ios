//
//  MenuSectionHeader.h
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@class JSBadgeView;

@interface MenuSectionHeader : BottomLineView {
    void (^_actionBlock)(MenuSectionHeader* header);
}

@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, readonly) JSBadgeView * badgeView;
@property (nonatomic, assign, getter=isselected) BOOL selected;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

- (void)setActionBlock:(void (^)(MenuSectionHeader* header))block;
- (void)setExpandable:(BOOL)expandable;

@end
