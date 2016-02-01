//
//  IQShareToMessageActivity.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 2/1/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQShareToMessageActivity.h"
#import "SharingNavigationController.h"
#import "IQAttachment.h"

@interface IQShareToMessageActivity ()

@property (nonatomic, strong) SharingNavigationController *sharingController;

@end

@implementation IQShareToMessageActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Share to messages", nil);
}

- (UIImage *)activityImage {
    return [[UIImage alloc] init];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    __block BOOL canPerform = false;
    
    [activityItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        *stop = canPerform = [obj isKindOfClass:[IQAttachment class]] && ((IQAttachment *)obj).localURL;
        if (canPerform) {
            IQAttachment *attachment = ((IQAttachment *)obj);
            NSURL *fileURL = [NSURL fileURLWithPath:attachment.localURL];
            *stop = canPerform = [fileURL isFileURL] && [fileURL checkResourceIsReachableAndReturnError:nil];
        }
    }];
    
    return canPerform;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    __block IQAttachment *attachment = nil;
    
    [activityItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        *stop = [obj isKindOfClass:[IQAttachment class]] && ((IQAttachment *)obj).localURL;
        if (*stop) {
            attachment = obj;
        }
    }];
    
    _sharingController = [[SharingNavigationController alloc] initWithSharingType:SharingTypeMessages attachments:attachment];
}

- (UIViewController *)activityViewController {
    return _sharingController;
}


@end
