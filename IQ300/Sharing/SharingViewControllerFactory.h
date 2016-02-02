//
//  SharingViewControllerFactory.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 02/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharingViewControllerProtocol.h"
#import "SharingConstants.h"
#import "SharingAttachment.h"

@interface SharingViewControllerFactory : NSObject

+ (UIViewController<SharingViewControllerProtocol> *)viewControllerForType:(SharingType)type withAttachment:(SharingAttachment *)attachemnt;

@end
