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

+ (instancetype)itemWithOnState:(BOOL)onState;

@end
