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
        stringDate = NSLocalizedString(@"Yesterday", nil);
    }
    else {
        NSDateFormatter *dateFormatter = [self dateFormater];
        [dateFormatter setDateFormat:(todayYearComp.year == dateYearComp.year) ? @"dd MMMM, HH:mm" : @"dd MMMM yyyy, HH:mm"];
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
