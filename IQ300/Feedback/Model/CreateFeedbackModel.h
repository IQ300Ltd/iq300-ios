//
//  FeedbackModel.h
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel+Subclass.h"

@interface CreateFeedbackModel : IQTableModel

@property (nonatomic, assign) CGFloat cellWidth;

- (NSString*)placeholderForItemAtIndexPath:(NSIndexPath*)indexPath;

- (NSString*)detailTitleForItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)updateFieldAtIndexPath:(NSIndexPath*)indexPath withValue:(id)value;

- (void)createFeedbackWithCompletion:(void (^)(NSError * error))completion;

- (BOOL)isAllFieldsValidWithError:(NSError**)error;

- (BOOL)modelHasChanges;

@end
