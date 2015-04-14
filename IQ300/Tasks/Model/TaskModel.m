//
//  TaskModel.m
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskModel.h"
#import "IQDetailsTextCell.h"
#import "IQTask.h"
#import "IQCommunity.h"
#import "NSDate+IQFormater.h"
#import "NSManagedObject+ActiveRecord.h"

static NSString * CellReuseIdentifier = @"CellReuseIdentifier";
static NSString * DateCellReuseIdentifier = @"DateCellReuseIdentifier";

@implementation TaskModel

- (id)init {
    self = [super init];
    if(self) {

    }
    return self;
}

- (void)setTask:(IQTask *)task {
    _task = task;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section < [self numberOfSections] &&
       indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        NSString * text = [_items objectAtIndex:indexPath.row];
        return ((NSNull*)text != [NSNull null] && [text length] > 0) ? text : nil;
    }
    return nil;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = (indexPath.row == 0) ? [IQEditableTextCell class] : [IQDetailsTextCell class];
    
    IQEditableTextCell * cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                 reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
    if (indexPath.row != 0) {
        IQDetailsTextCell * detailCell = (IQDetailsTextCell*)cell;
        UIImage * accessoryImage = (indexPath.row > 3) ? [UIImage imageNamed:@"calendar_accessory_image.png"] :
                                                         [UIImage imageNamed:@"right_gray_arrow.png"];
        detailCell.accessoryImage = accessoryImage;
    }
    
    return cell;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString * text = [self itemAtIndexPath:indexPath];
    if (indexPath.row < 3 && (NSNull*)text != [NSNull null] && [text length] > 0) {
        return (indexPath.row == 0) ? [IQEditableTextCell heightForItem:text width:self.cellWidth] :
                                      [IQDetailsTextCell heightForItem:text width:self.cellWidth];
   
    }
    return 50.0f;
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return CellReuseIdentifier;
}

- (NSString*)placeholderForItemAtIndexPath:(NSIndexPath*)indexPath {
    static NSArray * _placeholders = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _placeholders = @[@"Title", @"Description", @"Community", @"Executers", @"Begins", @"Ends"];
    });
    
    NSString * placeholder = (indexPath.row < [_placeholders count]) ? [_placeholders objectAtIndex:indexPath.row] : nil;
    return ((NSNull*)placeholder != [NSNull null] && [placeholder length] > 0) ? NSLocalizedString(placeholder, nil) : nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    NSError * error = nil;

    if (self.task == nil) {
        self.task = [self createTaskInContext:self.context error:&error];
    }
    
    [self initModelByTask];
    
    if (completion) {
        completion(error);
    }
}

#pragma mark - Private methods

- (void)initModelByTask {

    if (self.task) {
        if (self.task.executor) {
           // _executers = @[self.task.executor];
        }
        
        NSMutableArray * fields = [NSMutableArray array];
        
        [fields addObject:([self.task.title length] > 0) ? self.task.title : [NSNull null]];
        [fields addObject:([self.task.taskDescription length] > 0) ? self.task.taskDescription : [NSNull null]];
        [fields addObject:(self.task.community) ? self.task.community.title : [NSNull null]];
        
        if ([_executers count] > 0) {
            [fields addObject:[NSString stringWithFormat:@"%@: %lu", NSLocalizedString(@"Performers", nil), (unsigned long)[self.executers count]]];
        }
        else {
            [fields addObject:[NSNull null]];
        }
        
        NSString * dateFormat = @"dd.MM.yyyy HH:mm";
        if (self.task.startDate) {
            [fields addObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Begins", nil),
                               [self.task.startDate dateToStringWithFormat:dateFormat]]];
        }
        else {
            [fields addObject:[NSNull null]];
        }
        
        if (self.task.endDate) {
            [fields addObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Perform to", nil),
                               [self.task.endDate dateToStringWithFormat:dateFormat]]];
        }
        else {
            [fields addObject:[NSNull null]];
        }
        
        _items = [fields copy];
    }
}

- (IQTask*)createTaskInContext:(NSManagedObjectContext*)context error:(NSError**)error {
    IQTask * task = [IQTask createInContext:context];
    
    return task;
}

@end
