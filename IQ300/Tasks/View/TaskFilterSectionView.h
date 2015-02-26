//
//  TaskFilterSectionView.h
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@interface TaskFilterSectionView : BottomLineView {
    void (^_actionBlock)(TaskFilterSectionView * header);
    void (^_sortActionBlock)(TaskFilterSectionView * header);
}

@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSInteger section;

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isAscending) BOOL ascending;
@property (nonatomic, assign, getter=isSortAvailable) BOOL sortAvailable;

- (void)setActionBlock:(void (^)(TaskFilterSectionView* header))block;
- (void)setSortActionBlock:(void (^)(TaskFilterSectionView* header))block;
- (void)setExpandable:(BOOL)expandable;

@end
