//
//  TaskSubtasksModel.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 22/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTableManagedModel.h"

@interface TaskSubtasksModel : IQTableManagedModel

@property (nonatomic, strong) NSNumber *taskId;

@property (nonatomic, readonly) NSString * category;

@property (nonatomic, assign) CGFloat cellWidth;

//- (void)resetReadFlagWithCompletion:(void (^)(NSError * error))completion;

@end
