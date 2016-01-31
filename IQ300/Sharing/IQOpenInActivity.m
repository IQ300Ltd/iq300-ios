//
//  IQOpenInActivity.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 1/28/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQOpenInActivity.h"

@interface IQOpenInActivity ()

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation IQOpenInActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Open in ...", nil);
}

- (UIImage *)activityImage {
    return [[UIImage alloc] init];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    __block BOOL canPerform = false;
        
    [activityItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        *stop = canPerform = [obj isKindOfClass:[NSURL class]] && [((NSURL *)obj) isFileURL];
    }];
        
    return canPerform;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    __block NSURL *fileURL = nil;
    
    [activityItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSURL class]] && [((NSURL *)obj) isFileURL]) {
            fileURL = obj;
            *stop = YES;
        }
    }];
    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
}

- (void)performActivity {
    BOOL success = NO;
    if (_delegate) {
        success = [_delegate openInActivity:self didCreateDocumentInteractionController:_documentInteractionController];
    }
    [self activityDidFinish:success];
}



@end
