//
//  IQTextValidator.h
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQValueValidator <NSObject>

/**
 *  Validates the value
 *
 *  @param value value to validate
 */
- (BOOL)validate:(id)value error:(NSError**)error;

@end
