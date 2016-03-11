//
//  FeedbackCategoriesModel.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackCategoriesModel.h"
#import "FeedbackCategoryCell.h"
#import "IQFeedbackCategory.h"
#import "IQService+Feedback.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@interface FeedbackCategoriesModel() {
    NSArray *_filterIndexes;
}

@end

@implementation FeedbackCategoriesModel

- (id)init {
    self = [super init];
    if (self) {
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        self.sortDescriptors = @[descriptor];
    }
    return self;
}

- (NSString*)cacheFileName {
    return @"FeedbackCategoriesModelCache";
}

- (NSString*)entityName {
    return @"IQFeedbackCategory";
}

- (NSManagedObjectContext*)context {
    return [IQService sharedService].context;
}

- (Class)cellClassForIndexPath:(NSIndexPath *)indexPath {
    return [FeedbackCategoryCell class];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return CellReuseIdentifier;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    IQFeedbackCategory * item = [self itemAtIndexPath:indexPath];
    return [IQSelectableTextCell heightForItem:item.title detailTitle:nil width:self.cellWidth];
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    __weak typeof(self) weakSelf = self;
    [[IQService sharedService] feedbackCategoriesWithHandler:^(BOOL success, NSArray * items, NSData *responseData, NSError *error) {
        _filterIndexes = [items valueForKey:@"categoryId"];
        [weakSelf reloadModelSourceControllerWithCompletion:completion];
    }];
}

- (NSPredicate *)fetchPredicate {
    return [NSPredicate predicateWithFormat:@"SELF.categoryId IN %@", _filterIndexes];
}

@end
