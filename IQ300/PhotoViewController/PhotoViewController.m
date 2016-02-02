//
//  PhotoViewController.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "PhotoViewController.h"
#import "IQActivityViewController.h"

#define HEADER_HEIGHT 52.0f

@interface PhotoViewController() <UIScrollViewDelegate, IQActivityViewControllerDelegate, UIDocumentInteractionControllerDelegate> {
    UIImageView * _imageView;
    UIScrollView * _scrollView;
    UIActivityIndicatorView * _activityIndicator;
    UIDocumentInteractionController *_documentController;
}

@end

@implementation PhotoViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.title = self.fileName;
    
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
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
    self.navigationItem.rightBarButtonItem = shareButton;

}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.imageURL && !_imageView.image) {
        self.navigationItem.rightBarButtonItem.enabled = NO;

        [_activityIndicator startAnimating];
        [_imageView sd_setImageWithURL:self.imageURL
                      placeholderImage:nil
                               options:0
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
                                 self.navigationItem.rightBarButtonItem.enabled = YES;
                             }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

- (void)shareAction:(id)sender {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:_imageView.sd_imageURL];

    SharingAttachment *attachment = [[SharingAttachment alloc] initWithPath:[manager.imageCache defaultCachePathForKey:key]
                                                                displayName:_fileName
                                                                contentType:_contentType];
    
    IQActivityViewController *activityViewContoller = [[IQActivityViewController alloc] initWithAttachment:attachment];
    activityViewContoller.delegate = self;
    [self presentViewController:activityViewContoller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _imageView.image = nil;
}

#pragma mark - IQActivityViewControllerDelegate

- (BOOL)willShowDocumentInteractionController {
    return YES;
}

- (void)shouldShowDocumentInteractionController:(UIDocumentInteractionController *)controller fromRect:(CGRect)rect {
    _documentController = controller;
    [_documentController setDelegate:(id<UIDocumentInteractionControllerDelegate>)self];
    if(![_documentController presentOpenInMenuFromRect:rect inView:self.view animated:YES]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"You do not have an application installed to view files of this type", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    _documentController = nil;
}



@end
