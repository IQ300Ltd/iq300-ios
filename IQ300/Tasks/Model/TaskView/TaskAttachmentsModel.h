//
//  TAttachmentsModel.h
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TCManagedCollectionModel.h"

@class ALAsset;

@interface TaskAttachmentsModel : TCManagedCollectionModel

@property (nonatomic, readonly) NSString * category;

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSNumber * unreadCount;
@property (nonatomic, assign) BOOL resetReadFlagAutomatically;

- (void)addAttachmentWithAsset:(ALAsset*)asset
                      fileName:(NSString*)fileName
                attachmentType:(NSString*)type completion:(void (^)(NSError * error))completion;

- (void)resetReadFlagWithCompletion:(void (^)(NSError * error))completion;

@end
