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

@interface PhotoViewController() <UIScrollViewDelegate> {
    UIImageView * _imageView;
    UIScrollView * _scrollView;
    UIActivityIndicatorView * _activityIndicator;
}

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 6.0;
    _scrollView.contentSize = CGSizeMake(1280, 960);
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
 
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];

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
                                 if (!error) {
                                     [self updateView];
                                 }
                                 [_activityIndicator stopAnimating];
                             }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _imageView.image = nil;
    [_imageView sd_cancelCurrentImageLoad];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect actualBounds = self.view.bounds;
    _scrollView.frame = actualBounds;
    _activityIndicator.center = self.view.center;
}

#pragma mark - UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
    _imageView.frame = frameToCenter;
}

#pragma mark - Private methods

- (void)updateView {
    UIImage * img = _imageView.image;
    
    _scrollView.contentSize = CGSizeMake(img.size.width, img.size.height);
    _scrollView.contentMode = UIViewContentModeScaleAspectFit;
    _scrollView.clipsToBounds = YES;
    _scrollView.multipleTouchEnabled = YES;
    
    _imageView.frame = CGRectMake(0.0,
                                  0.0,
                                  img.size.width,
                                  img.size.height);
    
    CGFloat hRatio = _scrollView.frame.size.width / img.size.width;
    CGFloat vRatio = _scrollView.frame.size.height / img.size.height;
    
    CGFloat minZoom = MIN(hRatio, vRatio);
    
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.minimumZoomScale = minZoom;
    
    _scrollView.zoomScale = minZoom;
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _imageView.image = nil;
}

@end
