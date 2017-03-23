//
//  NSDate+BoundaryDates.h
//  IQ300
//
//  Created by Viktor Shabanov on 3/23/17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (BoundaryDates)

- (NSDate *)nextDay;
- (NSDate *)prevDay;

- (NSDate *)beginningOfDay;
- (NSDate *)endOfDay;

- (NSDate *)beginningOfWeek;
- (NSDate *)endOfWeek;

- (NSDate *)beginningOfMonth;
- (NSDate *)endOfMonth;

- (NSDate *)beginningOfYear;
- (NSDate *)endOfYear;

@end
