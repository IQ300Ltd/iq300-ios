//
//  MenuModel.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IQMenuModel.h"

@interface NotificationsMenuModel : NSObject<IQMenuModel>

@property (nonatomic, readonly) NSString * title;
@property (nonatomic, assign)   NSInteger unreadItemsCount;
@property (nonatomic, weak)     id<IQTableModelDelegate> delegate;

@end
