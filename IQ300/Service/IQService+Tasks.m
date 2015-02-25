//
//  IQService+Tasks.m
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService+Tasks.h"

@implementation IQService (Tasks)

- (void)tasksByFolder:(NSString*)folder
               status:(NSString*)status
          communityId:(NSNumber*)communityId
                 page:(NSNumber*)page
                  per:(NSNumber*)per
               search:(NSString*)search
                 sort:(IQSortDirection)sort
              handler:(ObjectLoaderCompletionHandler)handler {
    
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"folder"         : NSStringNullForNil(folder),
                                                                  @"status"         : NSStringNullForNil(status),
                                                                  @"by_community"   : NSObjectNullForNil(communityId),
                                                                  @"page"           : NSObjectNullForNil(page),
                                                                  @"per"            : NSObjectNullForNil(per),
                                                                  @"search"         : NSStringNullForNil(search)
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/tasks"
                parameters:parameters
                   handler:handler];

}

@end
