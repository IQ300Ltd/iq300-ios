//
//  IQOpenInActivity.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 1/28/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQOpenInActivity.h"
#import "SharingAttachment.h"
#import "SharingConstants.h"

@interface IQOpenInActivity ()

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation IQOpenInActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    NSString *activityType = [IQ_ACTIVITY_TYPE_PREFIX stringByAppendingString:@"openin"];
    return activityType;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Open in ...", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"open_in_icon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return activityItems.count > 0;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    SharingAttachment *attachment = activityItems.firstObject;
    NSString *fileURL = [[attachment.localURL stringByDeletingLastPathComponent] stringByAppendingString:[NSString stringWithFormat:@"/%@", attachment.displayName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fileURL]) {
        [fileManager removeItemAtPath:fileURL error:nil];
    }
    
    [fileManager copyItemAtPath:attachment.localURL toPath:fileURL error:nil];
    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fileURL]];
}

- (void)performActivity {
    BOOL success = NO;
    if (_delegate) {
        success = [_delegate openInActivity:self didCreateDocumentInteractionController:_documentInteractionController];
    }
    [self activityDidFinish:success];
}



@end
