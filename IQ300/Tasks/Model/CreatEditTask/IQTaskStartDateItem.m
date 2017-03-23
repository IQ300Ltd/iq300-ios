//
//  IQTaskStartDateItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskStartDateItem.h"
#import "NSDate+IQFormater.h"
#import "IQTaskDataHolder.h"
#import "NSDate+BoundaryDates.h"

@implementation IQTaskStartDateItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(startDate)], @"Task dont respond to estimated time selector");

    NSDate *date = [task startDate];
    NSString * dateFormat = @"dd.MM.yyyy HH:mm";

    NSString *placeholder = NSLocalizedString(@"Begins", nil);
    NSString *text = [NSString stringWithFormat:@"%@: %@", placeholder,
                               [date dateToStringWithFormat:dateFormat]];

    self = [super initWithText:text placeholder:placeholder];
    if (self) {
        self.accessoryImageName = @"calendar_accessory_image.png";
    }
    return self;
}

- (void)setTask:(id)task {
    NSDate *date = [task startDate];
    NSString * dateFormat = @"dd.MM.yyyy HH:mm";
    
    NSString *placeholder = NSLocalizedString(@"Begins", nil);
    NSString *text = [NSString stringWithFormat:@"%@: %@", placeholder,
                      [date dateToStringWithFormat:dateFormat]];

    self.text = text;
}

- (void)updateWithTask:(id)task value:(id)value {
    [task setStartDate:value];
    
    if ([[task startDate] compare:[task endDate]] != NSOrderedAscending) {
        [task setEndDate:[value endOfDay]];
    }
    
    if ([[task endDate] compare:[task parentEndDate]] == NSOrderedDescending) {
        [task setEndDate:[task parentEndDate]];
    }

    NSDate *date = value;
    NSString * dateFormat = @"dd.MM.yyyy HH:mm";
    
    NSString *placeholder = NSLocalizedString(@"Begins", nil);

    NSString *text = [NSString stringWithFormat:@"%@: %@", placeholder,
                      [date dateToStringWithFormat:dateFormat]];
    self.text = text;
}

@end
