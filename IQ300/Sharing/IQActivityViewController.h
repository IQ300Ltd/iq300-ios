//
//  IQActivityViewController.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 1/28/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IQActivityViewControllerDelegate;

@interface IQActivityViewController : UIActivityViewController

@property (nonatomic, weak) id<IQActivityViewControllerDelegate> delegate;
@property (nonatomic, assign) CGRect documentInteractionControllerRect;

- (instancetype _Nonnull)initWithActivityItems:(NSArray * _Nonnull)activityItems applicationActivities:(nullable NSArray<__kindof UIActivity *> *)applicationActivities NS_UNAVAILABLE;

- (instancetype _Nullable)initWithActivityItem:(nonnull id)activityItem applicationActivities:(nullable NSArray<__kindof UIActivity *> *)applicationActivities;

@end

@protocol IQActivityViewControllerDelegate <NSObject>

@optional

- (BOOL)willShowDocumentInteractionController;
- (void)shouldShowDocumentInteractionController:(UIDocumentInteractionController * _Nonnull)controller fromRect:(CGRect)rect;

@end
