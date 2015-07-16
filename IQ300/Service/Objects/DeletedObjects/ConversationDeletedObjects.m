//
//  ConversationDeletedObjects.m
//  IQ300
//
//  Created by Viktor Shabanov on 7/16/15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ConversationDeletedObjects.h"

@implementation ConversationDeletedObjects

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"deleted_conversation_ids" : @"objectIds",
                                                  @"current_date"             : @"serverDate"
                                                  }];
    return mapping;
}

@end
