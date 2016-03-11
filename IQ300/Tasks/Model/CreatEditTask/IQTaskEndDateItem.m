//
//  IQTaskEndDateItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskEndDateItem.h"
#import "NSDate+IQFormater.h"
#import "IQTask.h"

@implementation IQTaskEndDateItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(endDate)], @"Task dont respond to estimated time selector");
    
    NSDate *date = [task endDate];
    NSString * dateFormat = @"dd.MM.yyyy HH:mm";
    
    NSString *placeholder = NSLocalizedString(@"Perform to", nil);
    NSString *text = [NSString stringWithFormat:@"%@: %@", placeholder,
                      [date dateToStringWithFormat:dateFormat]];
    
    self = [super initWithText:text placeholder:placeholder];
    if (self) {
        self.accessoryImageName = @"calendar_accessory_image.png";
    }
    return self;
}

- (void)setTask:(id)task {
    NSDate *date = [task endDate];
    NSString * dateFormat = @"dd.MM.yyyy HH:mm";
    
    NSString *placeholder = NSLocalizedString(@"Perform to", nil);
    NSString *text = [NSString stringWithFormat:@"%@: %@", placeholder,
                      [date dateToStringWithFormat:dateFormat]];
    self.text = text;
}

- (void)updateWithTask:(id)task value:(id)value {
    [task setEndDate:value];
    
    NSDate *date = value;
    NSString * dateFormat = @"dd.MM.yyyy HH:mm";
    
    NSString *placeholder = NSLocalizedString(@"Perform to", nil);

    NSString *text = [NSString stringWithFormat:@"%@: %@", placeholder,
                      [date dateToStringWithFormat:dateFormat]];
    self.text = text;
}

@end