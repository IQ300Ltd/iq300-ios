//
//  TaskMembersModel.h
//  IQ300
//
//  Created by Tayphoon on 23.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface TaskMembersModel : NSObject <IQTableModel>

@property (nonatomic, readonly) NSArray * members;
@property (nonatomic, readonly) NSString * category;

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSString * sectionNameKeyPath;
@property (nonatomic, strong) NSPredicate * predicate;
@property (nonatomic, strong) NSArray  * sortDescriptors;
@property (nonatomic, strong) NSNumber * unreadCount;
@property (nonatomic, assign) BOOL resetReadFlagAutomatically;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (void)addMemberWithUserId:(NSNumber*)userId completion:(void (^)(NSError * error))completion;

- (void)removeMemberWithId:(NSNumber*)memberId completion:(void (^)(NSError * error))completion;

- (void)leaveTaskWithMemberId:(NSNumber*)memberId completion:(void (^)(NSError * error))completion;

- (void)resetReadFlagWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

@end
