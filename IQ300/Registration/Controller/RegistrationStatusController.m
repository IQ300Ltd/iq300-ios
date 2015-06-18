//
//  RegistrationStatusController.m
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "RegistrationStatusController.h"
#import "RegistrationStatusView.h"

@interface RegistrationStatusController() {
    RegistrationStatusView * _statusView;
}

@end

@implementation RegistrationStatusController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView {
    _statusView = [[RegistrationStatusView alloc] init];
    self.view = _statusView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_statusView.backButton addTarget:self
                               action:@selector(backButtonAction:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    _statusView.statusTextView.attributedText = self.statusMessage;
}

- (void)setStatusMessage:(NSAttributedString *)statusMessage {
    _statusMessage = statusMessage;
    if (self.isViewLoaded) {
        _statusView.statusTextView.attributedText = _statusMessage;
    }
}

#pragma mark - Private methods

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
