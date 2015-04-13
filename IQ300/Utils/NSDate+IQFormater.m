//
//  NSDate+IQFormater.m
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "NSDate+IQFormater.h"
#import "NSDate+CupertinoYankee.h"

@implementation NSDate (IQFormater)

- (NSDate *)randomDateInYearOfDate {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];
    
    [comps setMonth:arc4random_uniform(12)];
    
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[currentCalendar dateFromComponents:comps]];
    
    [comps setDay:arc4random_uniform((u_int32_t)range.length)];
    [comps setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    return [currentCalendar dateFromComponents:comps];
}

- (NSString*)dateToDayTimeString {
    NSString * stringDate = nil;
    NSDate * today = [[NSDate date] beginningOfDay];
    NSDate * yesterday = [today prevDay];
    NSDate * beginningOfDay = [self beginningOfDay];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents * todayYearComp = [calendar components:NSYearCalendarUnit fromDate:today];
    NSDateComponents * dateYearComp = [calendar components:NSYearCalendarUnit fromDate:self];

    
    if([beginningOfDay compare:today] == NSOrderedSame) {
        NSDateFormatter * timeFormatter = [self dateFormater];
        [timeFormatter setDateFormat:@"HH:mm"];
        stringDate = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Today", nil), [timeFormatter stringFromDate:self]];
    }
    else if([beginningOfDay compare:yesterday] == NSOrderedSame) {
        NSDateFormatter * timeFormatter = [self dateFormater];
        [timeFormatter setDateFormat:@"HH:mm"];
        stringDate = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Yesterday", nil), [timeFormatter stringFromDate:self]];
    }
    else {
        NSDateFormatter *dateFormatter = [self dateFormater];
        [dateFormatter setDateFormat:(todayYearComp.year == dateYearComp.year) ? @"dd MMMM, HH:mm" : @"dd MMMM yyyy, HH:mm"];
        stringDate = [dateFormatter stringFromDate:self];
    }
    
    return stringDate;
}

- (NSString*)dateToTimeDayString {
    NSString * stringDate = nil;
    NSDate * today = [[NSDate date] beginningOfDay];
    NSDate * yesterday = [today prevDay];
    NSDate * beginningOfDay = [self beginningOfDay];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents * todayYearComp = [calendar components:NSYearCalendarUnit fromDate:today];
    NSDateComponents * dateYearComp = [calendar components:NSYearCalendarUnit fromDate:self];
    
    
    if([beginningOfDay compare:today] == NSOrderedSame) {
        NSDateFormatter * timeFormatter = [self dateFormater];
        [timeFormatter setDateFormat:@"HH:mm"];
        stringDate = [NSString stringWithFormat:@"%@, %@", [timeFormatter stringFromDate:self], NSLocalizedString(@"Today", nil)];
    }
    else if([beginningOfDay compare:yesterday] == NSOrderedSame) {
        NSDateFormatter * timeFormatter = [self dateFormater];
        [timeFormatter setDateFormat:@"HH:mm"];
        stringDate = [NSString stringWithFormat:@"%@, %@", [timeFormatter stringFromDate:self], NSLocalizedString(@"Yesterday", nil)];
    }
    else {
        NSDateFormatter *dateFormatter = [self dateFormater];
        [dateFormatter setDateFormat:(todayYearComp.year == dateYearComp.year) ? @"HH:mm, dd MMMM" : @"HH:mm, dd MMMM yyyy"];
        stringDate = [dateFormatter stringFromDate:self];
    }
    
    return stringDate;
}

- (NSString*)dateToDayString {
    NSString * stringDate = nil;
    NSDate * today = [[NSDate date] beginningOfDay];
    NSDate * yesterday = [today prevDay];
    NSDate * beginningOfDay = [self beginningOfDay];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents * todayYearComp = [calendar components:NSYearCalendarUnit fromDate:today];
    NSDateComponents * dateYearComp = [calendar components:NSYearCalendarUnit fromDate:self];
    
    
    if([beginningOfDay compare:today] == NSOrderedSame) {
        stringDate = NSLocalizedString(@"Today", nil);
    }
    else if([beginningOfDay compare:yesterday] == NSOrderedSame) {
        stringDate = NSLocalizedString(@"Yesterday", nil);
    }
    else {
        NSDateFormatter *dateFormatter = [self dateFormater];
        [dateFormatter setDateFormat:(todayYearComp.year == dateYearComp.year) ? @"dd MMMM" : @"dd MMMM yyyy"];
        stringDate = [dateFormatter stringFromDate:self];
    }
    
    return stringDate;
}

- (NSString*)dateToTimeString {
    NSDateFormatter * timeFormatter = [self dateFormater];
    [timeFormatter setDateFormat:@"HH:mm"];
    return [timeFormatter stringFromDate:self];
}

- (NSString*)dateToStringWithFormat:(NSString*)format {
    NSDateFormatter * timeFormatter = [self dateFormater];
    [timeFormatter setDateFormat:format];
    return [timeFormatter stringFromDate:self];
}

- (NSDateFormatter *)dateFormater {
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
#ifdef USE_DEFAULT_LOCALIZATION
        NSLocale *en_US = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
        [dateFormatter setLocale:en_US];
#endif
    }
    
    return dateFormatter;
}

@end
