//
//  SharingViewControllerProtocol.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 2/1/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SharingAttachment;
@class SharingViewController;

@protocol SharingViewControllerProtocol <NSObject>

@property (nonatomic, weak) SharingViewController *sharingController;

- (instancetype)initWithAttachment:(SharingAttachment *)attachment;

@end
