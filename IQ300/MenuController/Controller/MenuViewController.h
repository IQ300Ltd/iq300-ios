//
//  MenuViewController.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IQMenuModel.h"

@interface MenuViewController : UIViewController <IQTableModelDelegate>

@property (nonatomic, strong) id<IQMenuModel> model;

@end
