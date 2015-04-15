//
//  PhotoViewController.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "PhotoViewController.h"

#define HEADER_HEIGHT 52.0f

@interface PhotoViewController () {
    UIImageView * _imageView;
    UIActivityIndicatorView * _activityIndicator;
}

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityIndicator setHidesWhenStopped:YES];
    [self.view addSubview:_activityIndicator];
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    self.title = self.fileName;
    
    [_activityIndicator startAnimating];
    if(self.imageURL) {
        [_imageView sd_setImageWithURL:self.imageURL
                      placeholderImage:nil
                               options:SDWebImageCacheMemoryOnly
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 if (_imageView.image.size.height <= _imageView.frame.size.height &&
                                     _imageView.image.size.width <= _imageView.frame.size.width) {
                                     _imageView.contentMode = UIViewContentModeCenter;
                                 }
                                 else {
                                     _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                 }
                                 [_activityIndicator stopAnimating];
                             }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_imageView.image.size.height <= _imageView.frame.size.height &&
        _imageView.image.size.width <= _imageView.frame.size.width) {
        _imageView.contentMode = UIViewContentModeCenter;
    }
    else {
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _imageView.image = nil;
    [_imageView sd_cancelCurrentImageLoad];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect actualBounds = self.view.bounds;
    _imageView.frame = actualBounds;
    _activityIndicator.center = self.view.center;
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _imageView.image = nil;
}

@end
