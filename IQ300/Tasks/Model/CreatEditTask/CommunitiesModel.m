//
//  CommunitiesModel.m
//  IQ300
//
//  Created by Tayphoon on 15.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "CommunitiesModel.h"
#import "IQDetailsTextCell.h"
#import "IQService+Tasks.h"
#import "IQCommunity.h"

@interface CommunitiesModel() {
}

@end

@implementation CommunitiesModel

- (id)init {
    self = [super init];
    if (self) {
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
        self.sortDescriptors = @[descriptor];
    }
    return self;
}

- (Class)cellClass {
    return [IQDetailsTextCell class];
}

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath *)indexPath {
    return [_selectedIndexPath isEqual:indexPath];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    IQCommunity * item = [self itemAtIndexPath:indexPath];
    return [IQDetailsTextCell heightForItem:item.title detailTitle:nil width:self.cellWidth];
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    [[IQService sharedService] taskCommunitiesWithHandler:^(BOOL success, NSArray * communities, NSData *responseData, NSError *error) {
        _items = communities;
        
        NSArray * communityIds = [_items valueForKey:@"communityId"];
        NSInteger selectedIndex = [communityIds indexOfObject:self.communityId];
        if (selectedIndex != NSNotFound) {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

@end
