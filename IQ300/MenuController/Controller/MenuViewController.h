//
//  MenuViewController.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IQMenuModel.h"

@class MTableHeaderView;
@class MenuViewController;

@protocol MenuResponderDelegate <NSObject>

@optional
- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface MenuViewController : UIViewController <IQTableModelDelegate>

@property (nonatomic, strong) id<IQMenuModel> model;
@property (nonatomic, strong) MTableHeaderView * tableHaderView;
@property (nonatomic, getter = isTableHaderHidden) BOOL tableHaderHidden;
@property (nonatomic, weak) id menuResponder;

- (void)reloadMenuWithCompletion:(void (^)())completion;

@end
