//
//  MessagesMenuModel.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 20/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQMenuModel.h"

@class IQCounters;

@interface MessagesMenuModel : NSObject <IQMenuModel>

@property (nonatomic, readonly) NSString * title;
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;



@end
