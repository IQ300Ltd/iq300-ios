//
//  NotificationsOptionItem.h
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationsOptionItem : NSObject

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, assign) BOOL onState;
@property (nonatomic, assign) BOOL enabled;

+ (instancetype)itemWithEnabled:(BOOL)enabled;
+ (instancetype)itemWithOnState:(BOOL)onState enabled:(BOOL)enabled;

@end
