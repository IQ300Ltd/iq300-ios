//
//  IQOnlineIndicator.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 05/04/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ONLINE_INDICATOR_SIZE 10.0f
#define ONLINE_INDICATOR_LEFT_OFFSET 5.0f

typedef NS_ENUM(NSUInteger, IQOnlineIndicatorStyle) {
    IQOnlineIndicatorStyleUser,
    IQOnlineIndicatorStyleCurrentUser,
};

@interface IQOnlineIndicator : UIView

@property (nonatomic, assign) IQOnlineIndicatorStyle style;
@property (nonatomic, assign) BOOL online;

@property (nonatomic, assign) CGFloat borderWidht;

@end
