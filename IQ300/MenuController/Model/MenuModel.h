//
//  MenuModel.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IQMenuModel.h"

@interface MenuModel : NSObject<IQMenuModel>

@property (weak) id<IQModelDelegate> delegate;

@end
