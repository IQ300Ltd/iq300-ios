//
//  NSDate+BoundaryDates.m
//  IQ300
//
//  Created by Viktor Shabanov on 3/23/17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "NSDate+BoundaryDates.h"

static NSCalendarUnit const MonthBoundarySignificantUnits = NSCalendarUnitYear | NSCalendarUnitMonth;
static NSCalendarUnit const WeekBoundarySignificantUnits  = MonthBoundarySignificantUnits | NSCalendarUnitWeekday | NSCalendarUnitDay;

@implementation NSDate (BoundaryDates)

#pragma mark - Day

- (NSDate *)nextDay {
    return [self addToUnit:NSCalendarUnitDay value:1];
}

- (NSDate *)prevDay {
    return [self addToUnit:NSCalendarUnitDay value:-1];
}

- (NSDate *)beginningOfDay {
    return [[NSCalendar currentCalendar] startOfDayForDate:self];
}

- (NSDate *)endOfDay {
    return [[[self beginningOfDay] nextDay] dateByAddingTimeInterval:-1];
}

- (NSDate *)beginningOfWorkDay {
    return [[NSCalendar currentCalendar] dateBySettingHour:8 minute:0 second:0 ofDate:self options:0];
}

- (NSDate *)endOfWorkDay {
    return [[NSCalendar currentCalendar] dateBySettingHour:18 minute:0 second:0 ofDate:self options:0];
}

#pragma mark - Week

- (NSDate *)beginningOfWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:WeekBoundarySignificantUnits fromDate:self];
    components.day -= (components.weekday == calendar.firstWeekday) ? 6 : components.weekday - 2;
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    return [[[self beginningOfWeek] addToUnit:NSCalendarUnitWeekOfMonth value:1] dateByAddingTimeInterval:-1];
}

#pragma mark - Month

- (NSDate *)beginningOfMonth {
    return [self leaveUnits:MonthBoundarySignificantUnits];
}

- (NSDate *)endOfMonth {
    return [[[self beginningOfMonth] addToUnit:NSCalendarUnitMonth value:1] dateByAddingTimeInterval:-1];
}

#pragma mark - Year

- (NSDate *)beginningOfYear {
    return [self leaveUnits:NSCalendarUnitYear];
}

- (NSDate *)endOfYear {
    return [[[self beginningOfYear] addToUnit:NSCalendarUnitYear value:1] dateByAddingTimeInterval:-1];
}

#pragma mark - Helpers

- (NSDate *)addToUnit:(NSCalendarUnit)unit value:(NSInteger)value {
    return [[NSCalendar currentCalendar] dateByAddingUnit:unit value:value toDate:self options:0];
}

- (NSDate *)settingUnit:(NSCalendarUnit)unit value:(NSInteger)value {
    return [[NSCalendar currentCalendar] dateBySettingUnit:unit value:value ofDate:self options:0];
}

- (NSDate *)leaveUnits:(NSCalendarUnit)units {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:units fromDate:self];
    
    return [calendar dateFromComponents:components];
}

@end
