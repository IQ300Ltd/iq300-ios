//
//  FeedbackTypesModel.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackTypesModel.h"
#import "FeedbackTypeCell.h"
#import "IQFeedbackType.h"
#import "IQService+Feedback.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";

@implementation FeedbackTypesModel

- (id)init {
    self = [super init];
    if (self) {
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        self.sortDescriptors = @[descriptor];
    }
    return self;
}

- (NSString*)cacheFileName {
    return @"FeedbackTypesModelCache";
}

- (NSString*)entityName {
    return @"IQFeedbackType";
}

- (NSManagedObjectContext*)context {
    return [IQService sharedService].context;
}

- (Class)cellClass {
    return [FeedbackTypeCell class];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return CellReuseIdentifier;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    IQFeedbackType * item = [self itemAtIndexPath:indexPath];
    return [IQSelectableTextCell heightForItem:item.title detailTitle:nil width:self.cellWidth];
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    if([_fetchController.fetchedObjects count] == 0) {
        [self reloadModelSourceControllerWithCompletion:completion];
    }

    [[IQService sharedService] feedbackTypesWithHandler:^(BOOL success, id object, NSData *responseData, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
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