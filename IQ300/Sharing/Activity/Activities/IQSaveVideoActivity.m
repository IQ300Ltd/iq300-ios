//
//  IQSaveVideoActivity.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 16/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQSaveVideoActivity.h"
#import "SharingConstants.h"
#import "SharingAttachment.h"

@interface IQSaveVideoActivity()

@property (nonatomic, strong) NSString *videoURL;

@end

@implementation IQSaveVideoActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    NSString *activityType = [IQ_ACTIVITY_TYPE_PREFIX stringByAppendingString:@"savevideo"];
    return activityType;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Save video", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"save_video_icon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
//    if (activityItems.count > 0) {
//        SharingAttachment * attachment = [activityItems.firstObject isKindOfClass:[SharingAttachment class]] ? activityItems.firstObject : nil;
//        if (attachment) {
//            if ([attachment.contentType hasPrefix:@"video"]) {
//                return UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(attachment.localURL);
//            }
//        }
//    }
    return activityItems.count > 0;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    SharingAttachment * attachment = activityItems.firstObject;
    _videoURL = attachment.localURL;
}

- (void)performActivity {
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_videoURL)) {
        UISaveVideoAtPathToSavedPhotosAlbum(_videoURL, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    else {
        [self activityDidFinish:NO];
    }
}

- (void)video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    if (error) {
        NSLog(@"Video saving error: %@", error);
    }
    [self activityDidFinish:!error];
}


@end
