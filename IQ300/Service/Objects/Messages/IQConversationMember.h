//
//  IQConversationMember.h
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

@class RKObjectMapping;

@class IQUser;

@interface IQConversationMember : NSObject

@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * nickName;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * thumbUrl;
@property (nonatomic, strong) NSString * mediumUrl;
@property (nonatomic, strong) NSString * normalUrl;
@property (nonatomic, strong) NSNumber * isAdministrator;
@property (nonatomic, strong) NSNumber * online;

+ (RKObjectMapping*)objectMapping;

+ (IQConversationMember*)meberFromUser:(IQUser*)user;

@end
