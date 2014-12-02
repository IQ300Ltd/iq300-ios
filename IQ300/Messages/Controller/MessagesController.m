//
//  MessagesController.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "MessagesController.h"
#import "UIViewController+LeftMenu.h"
#import "MessagesView.h"

@interface MessagesController() {
    MessagesView * _messagesView;
}

@end

@implementation MessagesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Messages", nil);
        UIImage * barImage = [[UIImage imageNamed:@"messages_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"messgaes_tab_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImageSel];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
    }
    return self;
}

- (void)loadView {
    _messagesView = [[MessagesView alloc] init];
    self.view = _messagesView;
}

- (UITableView*)tableView {
    return _messagesView.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createNewMessage.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self action:@selector(createNewAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    
    [self.leftMenuController setModel:nil];
    [self.leftMenuController reloadMenuWithCompletion:nil];
}

#pragma mark - Private method

- (void)createNewAction:(id)sender {
    
}

@end
