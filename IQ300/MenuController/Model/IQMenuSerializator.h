//
//  IQMenuSerializator.h
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQMenuSerializator : NSObject

+ (NSArray*)serializeMenuFromList:(NSString*)pList error:(NSError**)error;

@end
