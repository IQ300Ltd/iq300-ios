//
//  IQConversation.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQComment.h"
#import "IQDiscussion.h"

@interface IQConversation : NSManagedObject

@property (nonatomic, strong) NSNumber * conversationId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * ownerId;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSNumber * creatorId;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSNumber * unreadCommentsCount;
@property (nonatomic, strong) NSNumber * totalCommentsCount;
@property (nonatomic, strong) NSSet * users;
@property (nonatomic, strong) IQDiscussion * discussion;
@property (nonatomic, strong) IQComment * lastComment;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

+ (void)removeLocalConversationWithId:(NSNumber *)conversationId;

@end
