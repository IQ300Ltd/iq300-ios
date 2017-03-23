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
#ifdef IPAD
    UIPopoverController *_popoverController;
#endif
}

@property (nonatomic, assign, readwrite, getter=isLoaded) BOOL loaded;

@end

@implementation PhotoViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.title = self.fileName;
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.multipleTouchEnabled = YES;
    [self.view addSubview:_scrollView];
 
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor clearColor];
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
    
    if(_imageURL && !_loaded) {
        [_activityIndicator startAnimating];
        self.navigationItem.rightBarButtonItem.enabled = NO;

        UIImage *previewImage = nil;
        
        if (_previewURL) {
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:_previewURL];
            previewImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
            [_imageView setImage:previewImage];
        }
        
        [_imageView sd_setImageWithURL:self.imageURL
                      placeholderImage:previewImage
                               options:0
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 if (!error) {
                                     _loaded = YES;
                                     self.navigationItem.rightBarButtonItem.enabled = YES;
                                     [self updateView];
                                 }
                                 [_activityIndicator stopAnimating];
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
    [self updateView];
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
    UIImage * image = _imageView.image;
    
    CGSize viewSize = self.view.bounds.size;
    CGSize contentSize = CGSizeZero;
    UIViewContentMode contentMode = UIViewContentModeCenter;
    
    if (image.size.width <= viewSize.width && image.size.height <= viewSize.height) {
        contentSize = self.view.bounds.size;
        contentMode = _loaded ? UIViewContentModeCenter : UIViewContentModeScaleAspectFit;
    }
    else {
        contentSize = image.size;
        contentMode = UIViewContentModeCenter;
    }
    
    _scrollView.zoomScale = 1.0f;
    _scrollView.minimumZoomScale = 1.0f;
    _scrollView.frame = self.view.bounds;

    
    _scrollView.contentSize = CGSizeMake(contentSize.width < viewSize.width ? viewSize.width : contentSize.width,
                                         contentSize.height < viewSize.height ? viewSize.height : contentSize.height);
    
    _imageView.contentMode = contentMode;
    _imageView.frame = CGRectMake(0,
                                  0,
                                  contentSize.width,
                                  contentSize.height);

    
    CGFloat hRatio = _scrollView.bounds.size.width / contentSize.width;
    CGFloat vRatio = _scrollView.bounds.size.height / contentSize.height;
    CGFloat minZoom = MIN(hRatio, vRatio);
    
    _scrollView.minimumZoomScale = minZoom;
    _scrollView.zoomScale = minZoom;
}

- (void)backButtonAction:(UIButton*)sender {
#ifdef IPAD
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
#endif
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction:(id)sender {
#ifdef IPAD
    if (self.presentedViewController){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
#endif
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:_imageView.sd_imageURL];

    SharingAttachment *attachment = [[SharingAttachment alloc] initWithPath:[manager.imageCache defaultCachePathForKey:key]
                                                                displayName:_fileName
                                                                contentType:_contentType];
    
    IQActivityViewController *controller = [[IQActivityViewController alloc] initWithAttachment:attachment];
    controller.delegate = self;
    
#ifdef IPAD
    UIPopoverPresentationController *popoverController = [controller popoverPresentationController];
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverController.barButtonItem = self.navigationItem.rightBarButtonItem;
#endif
        
    [self presentViewController:controller animated:YES completion:nil];
        
#ifdef IPAD 
    }
#endif

}

#ifdef IPAD
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _popoverController = nil;
}
#endif


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
    if(![_documentController presentOpenInMenuFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES]) {
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
