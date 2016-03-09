//
//  IQShareToMessageActivity.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 2/1/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQShareToMessageActivity.h"
#import "SharingViewController.h"
#import "IQManagedAttachment.h"
#import "SharingConstants.h"

@interface IQShareToMessageActivity ()

@property (nonatomic, strong) SharingViewController *sharingController;

@end

@implementation IQShareToMessageActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    return [IQ_ACTIVITY_TYPE_PREFIX stringByAppendingString:@"sharetomessage"];
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Share to messages", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"copy_to_message_icon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return activityItems.count > 0;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    SharingAttachment *attachment = activityItems.firstObject;
    _sharingController = [[SharingViewController alloc] initWithSharingType:SharingTypeMessages attachment:attachment activity:self];
}

- (UIViewController *)activityViewController {
    return _sharingController;
}


@end
