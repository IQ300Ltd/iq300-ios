//
//  IQNotificationsHolder.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQNotification.h"

@interface IQNotificationsHolder : NSObject

@property (nonatomic, strong) NSArray * notifications;
@property (nonatomic, strong) NSNumber * currentPage;
@property (nonatomic, strong) NSNumber * totalPages;
@property (nonatomic, strong) NSNumber * totalCount;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
