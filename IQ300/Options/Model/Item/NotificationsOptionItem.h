//
//  NotificationsOptionItem.h
//  IQ300
//
//  Created by Viktor Shabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationsOptionItem : NSObject

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, assign) BOOL onState;
@property (nonatomic, assign) BOOL enabledInteractions;

+ (instancetype)itemWithEnabledInteractions:(BOOL)enabled;
+ (instancetype)itemWithOnState:(BOOL)onState enabledInteractions:(BOOL)enabled;

@end
