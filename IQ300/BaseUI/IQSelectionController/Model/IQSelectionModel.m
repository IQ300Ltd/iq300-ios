//
//  IQSelectionModel.m
//  IQ300
//
//  Created by Tayphoon on 24.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQSelectionModel.h"
#import "IQSelectableTextCell.h"

@implementation IQSelectionModel

- (id)init {
    self = [super init];
    if (self) {
        _selectedIndexPaths = [[NSMutableArray alloc] init];
    }
    return self;
}

- (Class)cellClass {
    return [IQSelectableTextCell class];
}

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath {
    return [_selectedIndexPaths containsObject:indexPath];
}

- (void)makeItemAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    if (self.allowsMultipleSelection) {
        if (selected && ![_selectedIndexPaths containsObject:indexPath]) {
            [_selectedIndexPaths addObject:indexPath];
        }
        else if(!selected && [_selectedIndexPaths containsObject:indexPath]) {
            [_selectedIndexPaths removeObject:indexPath];
        }
    }
    else {
        [_selectedIndexPaths removeAllObjects];
        if (selected) {
            [_selectedIndexPaths addObject:indexPath];
        }
    }
}

- (NSIndexPath*)selectedIndexPathForSection:(NSInteger)section {
    return [[_selectedIndexPaths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"section == %d", section]] firstObject];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    return [IQSelectableTextCell heightForItem:item detailTitle:nil width:self.cellWidth];
}

- (void)setSubscribedToNotifications:(BOOL)subscribed {
    if(subscribed) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
}

#pragma mark - Private methods

- (void)applicationWillEnterForeground {
    [self updateModelWithCompletion:^(NSError *error) {
        [self modelDidChanged];
    }];
}

@end
