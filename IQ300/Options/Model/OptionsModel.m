//
//  OptionsModel.m
//  IQ300
//
//  Created by Viktor Shabanov on 03.04.17.
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
    
    BOOL _enabledInteraction;
    BOOL _granted;
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

- (void)clearModelData {
    _enabledInteraction = YES;
    _items = @[ [NotificationsOptionItem itemWithEnabledInteractions:_enabledInteraction] ];
}

- (void)updateModelWithInteractionEnable:(BOOL)enable
                              completion:(void (^)(BOOL success, BOOL granted, NSError * error))completion {
    
    _enabledInteraction = enable;
    [self updateModelWithCompletion:^(NSError *error) {
        NotificationsOptionItem *item = [_items firstObject];
        
        if (completion) {
            completion(!error, item.onState, error);
        }
    }];
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] pushNotificationsSettingsWithHandler:^(BOOL success, IQSettings *settings, NSData *responseData, NSError *error) {
         if (success && !error) {
             _items = @[
                        [NotificationsOptionItem itemWithOnState:[settings.pushEnabled boolValue]
                                             enabledInteractions:success ? YES : _enabledInteraction]
                        ];
         }
         
         if (completion) {
             completion(error);
         }
     }];
}

@end
