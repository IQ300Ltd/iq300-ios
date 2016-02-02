//
//  IQOpenInActivity.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 1/28/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IQOpenInActivityDelegate;

@interface IQOpenInActivity : UIActivity

@property (nonatomic, weak) id<IQOpenInActivityDelegate> delegate;

@end

@protocol IQOpenInActivityDelegate <NSObject>

- (BOOL)openInActivity:(IQOpenInActivity * _Nonnull)activity didCreateDocumentInteractionController:(UIDocumentInteractionController * _Nonnull)controller;

@end
