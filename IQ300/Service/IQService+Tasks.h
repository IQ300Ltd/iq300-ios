//
//  IQService+Tasks.h
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService.h"

@interface IQService (Tasks)

- (void)tasksByFolder:(NSString*)folder
               status:(NSString*)status
          communityId:(NSNumber*)communityId
                 page:(NSNumber*)page
                  per:(NSNumber*)per
               search:(NSString*)search
                 sort:(IQSortDirection)sort
              handler:(ObjectLoaderCompletionHandler)handler;

@end
