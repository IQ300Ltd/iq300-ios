//
//  FeedbackCell.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "FeedbackCell.h"
#import "IQManagedFeedback.h"

@implementation FeedbackCell

+ (NSString*)imageNameForFeedbackType:(NSString*)type {
    static NSDictionary * _imageNames = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _imageNames = @{
                                @"proposal" : @"feedback_proposal_type.png",
                                @"question" : @"feedback_question_type.png",
                                @"error"    : @"feedback_error_type.png"
                                };
    });
    
    if([_imageNames objectForKey:type]) {
        return [_imageNames objectForKey:type];
    }
    
    return nil;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (CGFloat)heightForItem:(IQManagedFeedback *)item andCellWidth:(CGFloat)cellWidth {
    return 50;
}

- (void)setItem:(IQManagedFeedback *)item {
    _item = item;
    self.textLabel.text = item.feedbackDescription;
}

@end
