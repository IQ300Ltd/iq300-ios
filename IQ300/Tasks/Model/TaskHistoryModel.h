//
//  TaskHistoryModel.h
//  IQ300
//
//  Created by Tayphoon on 01.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface TaskHistoryModel : NSObject<IQTableModel>

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion;

@end
