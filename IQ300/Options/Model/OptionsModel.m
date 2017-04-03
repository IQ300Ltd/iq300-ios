//
//  OptionsModel.m
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "OptionsModel.h"
#import "IQSettings.h"

typedef NS_ENUM(NSUInteger, OptionsModelCellTypes) {
    OptionsModelCellTypeNotications
};

static NSDictionary *_cellReuseIdentifiers = nil;
static NSDictionary *_cellClasses = nil;

@interface OptionsModel() {
    NSArray *_types;
}

@property (nonatomic, readwrite) NSArray *items;

@end

@implementation OptionsModel

@dynamic items;

#pragma mark - Cells Factory methods

#pragma mark -

- (id)init {
    self = [super init];
    if(self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _cellClasses = @{
                             @(OptionsModelCellTypeNotications) : [NotificationsOptionTableViewCell class]
                             };
            
            _cellReuseIdentifiers = @{
                                      @(OptionsModelCellTypeNotications) : @"OptionsCellReuseIdentifier"
                                      };
        });
        
        _enableInteraction = YES;
        _types = @[@(OptionsModelCellTypeNotications)];
        
        [self clearModelData];
    }
    
    return self;
}

- (id)typeAtIndexPath:(NSIndexPath *)indexPath {
    return [_types objectAtIndex:indexPath.row];
}

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath {
    return [_cellReuseIdentifiers objectForKey:[self typeAtIndexPath:indexPath]];
}

- (Class)cellClassForIndexPath:(NSIndexPath*)indexPath {
    return [_cellClasses objectForKey:[self typeAtIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 50.0f;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService]
     pushNotificationsSettingsWithHandler:^(BOOL success, IQSettings *settings, NSData *responseData, NSError *error) {
        if (success && !error) {
            _items = @[
                       [NotificationsOptionItem  itemWithOnState:[settings.pushEnabled boolValue]
                                                         enabled:_enableInteraction]
                       ];
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

- (void)clearModelData {
    _items = @[
               [NotificationsOptionItem itemWithEnabled:_enableInteraction]
               ];
}

@end
