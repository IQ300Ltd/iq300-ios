//
//  IQTask.m
//  IQ300
//
//  Created by Tayphoon on 20.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTask.h"
#import "NSDate+IQFormater.h"

@implementation IQTask

+ (IQTask*)randomTask {
    IQTask * task = [[IQTask alloc] init];
    
    task.taskID = [NSString stringWithFormat:@"#%d", random_range(1, 999999)];
    task.dueDate = [[NSDate date] randomDateInYearOfDate];
    task.title = (random_range(0, 1) == 0) ? @"Длинное название задачи в несколько строчек" : @"Короткое название задачи";
    task.fromUser = (random_range(0, 1) == 0) ? @"Иванов Иван" : @"Александр Иванович";
    task.toUser = (random_range(0, 1) == 0) ? @"Иванов Иван" : @"Сергеев Сергей Сергеевич";
    task.communityName = (random_range(0, 1) == 0) ? @"«Муниципальное авто- номное учреждение города Таганрога" : @"Сообшество";
    task.unreadMessagesCount = @(random_range(0, 135));
    task.status = (random_range(0, 1) == 0) ? @"В работе" : @"Инициализация";

    return task;
}

@end
