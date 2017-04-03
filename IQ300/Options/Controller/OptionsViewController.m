//
//  OptionsViewController.m
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "OptionsViewController.h"
#import "AppDelegate.h"
#import "DispatchAfterExecution.h"

#define DISPATCH_DELAY 1.f

@interface OptionsViewController () {
    dispatch_after_block _cancelBlock;
}

@end

@implementation OptionsViewController

@dynamic model;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.model = [[OptionsModel alloc] init];
        
        self.title = NSLocalizedString(@"Options", nil);
        
        float imageOffset = 6;
        UIImage * barImage = [[UIImage imageNamed:@"settings_ico.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"settings_ico_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:barImage selectedImage:barImageSel];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
    }
    
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifndef IPAD
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
#endif
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.model.enableInteraction = [AppDelegate pushNotificationsEnabled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadModel)
                                                 name:DeviceDidRegisterForPushesNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadModel];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self layoutTabelView];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    if ([cell conformsToProtocol:@protocol(IQTableCell)]) {
        ((id <IQTableCell>)cell).item = [self.model itemAtIndexPath:indexPath];
    }
    if ([cell isKindOfClass:[NotificationsOptionTableViewCell class]]) {
        [((NotificationsOptionTableViewCell *)cell).notificationsSwitch addTarget:self
                                                                           action:@selector(notificationsEnabledSwitchWasChanged:)
                                                                 forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

#pragma mark - Private methods

- (void)layoutTabelView {
    CGRect actualBounds = self.view.bounds;
    
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      actualBounds.origin.y + actualBounds.size.height);
}

#pragma mark - Navigation actions

- (void)backButtonAction:(UIButton*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)notificationsEnabledSwitchWasChanged:(UISwitch *)sender {
    if(_cancelBlock) {
        cancel_dispatch_after_block(_cancelBlock);
    }
    
    __weak typeof(self) weakSelf = self;
    BOOL enabled = sender.isOn;
    _cancelBlock = dispatch_after_delay(DISPATCH_DELAY, dispatch_get_main_queue(), ^{
        if (weakSelf.model.notificationsEnabeld != enabled) {
            [[IQService sharedService] makePushNotificationsEnabled:sender.isOn
                                                            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    if (!success) {
                                                                        [sender setOn:!enabled animated:YES];
                                                                        
                                                                        [weakSelf showWarning];
                                                                    }
                                                                    else {
                                                                        weakSelf.model.notificationsEnabeld = enabled;
                                                                    }
                                                                });
                                                            }];
        }
    });
}

- (void)willEnterForegroundNotification {
    if (self.model.enableInteraction != [AppDelegate pushNotificationsEnabled]) {
        self.model.enableInteraction = [AppDelegate pushNotificationsEnabled];
        
        if (self.model.enableInteraction && ![[IQService sharedService] isRegisterDeviceForRemoteNotifications]) {
            [AppDelegate registerForRemoteNotifications];
        }
        else {
            [self reloadModel];
        }
        
        
    }
}

- (void)reloadModel {
    [self.model updateModelWithCompletion:^(NSError *error) {
        if (!error) {
            [self.tableView reloadData];
        }
    }];
}

- (void)showWarning {
    [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                       message:NSLocalizedString(@"Setting could not be saved. Check your internet connection and try later", nil)
             cancelButtonTitle:NSLocalizedString(@"OK", nil)
             otherButtonTitles:nil
                      tapBlock:nil];
}

@end
