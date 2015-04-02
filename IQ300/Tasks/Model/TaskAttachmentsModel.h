//
//  TAttachmentsModel.h
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class ALAsset;

@interface TaskAttachmentsModel : NSObject<IQTableModel>

@property (nonatomic, readonly) NSString * category;

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) NSNumber * unreadCount;
@property (nonatomic, assign) BOOL resetReadFlagAutomatically;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (void)addAttachmentWithAsset:(ALAsset*)asset
                      fileName:(NSString*)fileName
                attachmentType:(NSString*)type completion:(void (^)(NSError * error))completion;

- (void)resetReadFlagWithCompletion:(void (^)(NSError * error))completion;

@end
