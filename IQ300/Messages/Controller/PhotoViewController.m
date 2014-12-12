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
    UIView * _headerView;
    UIButton * _backButton;
    UILabel * _titleLabel;
    UIActivityIndicatorView * _activityIndicator;
}

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_imageView];

    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor blackColor];
    _headerView.opaque = NO;
    _headerView.alpha = 0.7f;
    [self.view addSubview:_headerView];
 
    _backButton = [[UIButton alloc] init];
    [_backButton setImage:[UIImage imageNamed:@"backWhiteArrow.png"] forState:UIControlStateNormal];
    [[_backButton imageView] setContentMode:UIViewContentModeCenter];
    [_headerView addSubview:_backButton];
    
    _titleLabel = [[UILabel alloc] init];
    [_titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_headerView addSubview:_titleLabel];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityIndicator setHidesWhenStopped:YES];
    [self.view addSubview:_activityIndicator];

    [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _titleLabel.text = self.fileName;
    
    [_activityIndicator startAnimating];
    if(self.imageURL) {
        [_imageView sd_setImageWithURL:self.imageURL
                      placeholderImage:nil
                               options:SDWebImageCacheMemoryOnly
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 [_activityIndicator stopAnimating];
                             }];
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
    _headerView.frame = CGRectMake(actualBounds.origin.x,
                                   actualBounds.origin.y,
                                   actualBounds.size.width,
                                   HEADER_HEIGHT);
    
    CGSize backButtonImageSize = [_backButton imageForState:UIControlStateNormal].size;
    _backButton.frame = CGRectMake(13.0f,
                                   (_headerView.frame.size.height - backButtonImageSize.height) / 2,
                                   backButtonImageSize.width,
                                   backButtonImageSize.height);
    
    _titleLabel.frame = _headerView.bounds;
    
    //CGFloat imageY = CGRectBottom(_headerView.frame);
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
