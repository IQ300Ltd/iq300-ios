//
//  PhotoViewController.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController

@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, strong) NSURL * imageURL;
@property (nonatomic, strong) NSURL * previewURL;
@property (nonatomic, strong) NSString *contentType;

@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;

@end

