//
//  ViewController.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "TasksController.h"
#import "UIViewController+LeftMenu.h"

@interface TasksController ()

@end

@implementation TasksController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage * barImage = [[UIImage imageNamed:@"tasks_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"tasks_tab_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Tasks", nil) image:barImage selectedImage:barImageSel];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.leftMenuController setModel:nil];
    [self.leftMenuController reloadMenuWithCompletion:nil];
}

@end
