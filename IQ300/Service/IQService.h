//
//  IQService.h
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "TCService+Subclass.h"
#import "IQSession.h"

#define SERVICE_RESET_PASSWORD_URL [NSString stringWithFormat:@"%@/%@", SERVER_URL, @"users/password/new"]

typedef NS_ENUM(NSUInteger, IQSortDirection) {
    IQSortDirectionNo = -1,
    IQSortDirectionAscending  = 0,
    IQSortDirectionDescending = 1,
};

/**
 ParametersExcludeEmpty.
 
 @param parameters. Look `NSDictionary`.
 @return Dictionary with out empty parameters
 */
extern NSDictionary * IQParametersExcludeEmpty(NSDictionary * parameters);

extern NSString * IQSortDirectionToString(IQSortDirection direction);

@interface IQService : TCService

@property (nonatomic, strong) IQSession * session;

- (void)loginWithDeviceToken:(NSString*)deviceToken email:(NSString*)email password:(NSString*)password handler:(RequestCompletionHandler)handler;

- (void)logout;

- (void)signupWithFirstName:(NSString*)firstName
                   lastName:(NSString*)lastName
             communityTitle:(NSString*)communityTitle
                      email:(NSString*)email
                   password:(NSString*)password
                    handler:(RequestCompletionHandler)handler;

- (void)confirmRegistrationWithToken:(NSString*)token deviceToken:(NSString*)deviceToken handler:(RequestCompletionHandler)handler;

- (void)userInfoWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)registerDeviceForRemoteNotificationsWithToken:(NSString*)token handler:(RequestCompletionHandler)handler;

- (void)createAttachmentWithAsset:(ALAsset*)asset fileName:(NSString*)fileName mimeType:(NSString *)mimeType handler:(ObjectRequestCompletionHandler)handler;

- (void)createAttachmentWithFileAtPath:(NSString*)filePath fileName:(NSString*)fileName mimeType:(NSString *)mimeType handler:(ObjectRequestCompletionHandler)handler;

- (void)createAttachmentWithImage:(UIImage*)image fileName:(NSString*)fileName mimeType:(NSString *)mimeType handler:(ObjectRequestCompletionHandler)handler;

@end
