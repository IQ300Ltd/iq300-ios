//
//  NSDate+IQFormater.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (IQFormater)

- (NSString*)dateToDayTimeString;
- (NSString*)dateToTimeString;
- (NSString*)dateToStringWithFormat:(NSString*)format;

@end
