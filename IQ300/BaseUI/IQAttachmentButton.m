//
//  AttachmentView.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 09/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQAttachmentButton.h"
#import "IQManagedAttachment.h"
#import <UIImageView+WebCache.h>

@implementation IQAttachmentButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _roundRectContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _roundRectContainer.layer.cornerRadius = 5.0f;
        _roundRectContainer.layer.masksToBounds = YES;
        _roundRectContainer.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f].CGColor;
        _roundRectContainer.layer.borderWidth = 0.5f;
        [self addSubview:_roundRectContainer];
        
        _customImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_roundRectContainer addSubview:_customImageView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setNumberOfLines:2];
        [_label setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setFont:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 12 : 11.0f]];
        [_label setTextColor:[UIColor blackColor]];
        
        [_roundRectContainer addSubview:_label];
        
        _defaultColor = [UIColor colorWithHexInt:0xcaddee];
        _mineColor = [UIColor colorWithHexInt:0xe0e0e0];
        
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_deleteButton setImage:[UIImage imageNamed:@"close-circle.png"] forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _roundRectContainer.frame = self.bounds;
    
    CGSize size = self.bounds.size;
    
    CGFloat labelHeight = size.height - size.width;
    
    [_customImageView setFrame:CGRectMake(0, 0, size.width, size.height - labelHeight)];
    [_label setFrame:CGRectMake(2.0f, size.height - labelHeight, size.width - 4.0f, labelHeight)];
    
    CGSize deleteImageSize = [_deleteButton imageForState:UIControlStateNormal].size;
    [_deleteButton setFrame:CGRectMake(size.width - deleteImageSize.width / 2.0f, - deleteImageSize.height / 2.0f, deleteImageSize.width, deleteImageSize.height)];
}

- (void)setItem:(id<IQAttachment>)attachment isMine:(BOOL)isMine {
    [self setItem:attachment isMine:isMine showDeleteButton:NO];
}

- (void)setItem:(id<IQAttachment>)attachment isMine:(BOOL)isMine showDeleteButton:(BOOL)show {
    UIImage *plasehodler = [UIImage imageNamed:@"document_placeholder"];
    
    if (attachment.previewURL && attachment.previewURL.length > 0) {
        __weak typeof(self) weakSelf = self;
        
        NSURL *url = [NSURL URLWithString:attachment.previewURL];
        
//        if (url.scheme.length == 0 && url) {
//            <#statements#>
//        }
//        
        [_customImageView sd_setImageWithURL:[NSURL URLWithString:attachment.previewURL]
                            placeholderImage:plasehodler
                                     options:0
                                   completed:^(UIImage *image,
                                               NSError *error,
                                               SDImageCacheType
                                               cacheType,
                                               NSURL *imageURL) {
                                       [weakSelf setNeedsLayout];
                                   }];
    }
    else {
        [_customImageView setImage:plasehodler];
    }
    
    _roundRectContainer.backgroundColor = isMine ? _mineColor : _defaultColor;
    
    [_label setText:attachment.displayName];
    
    [self setNeedsLayout];
    
    self.deleteButtonShown = show;
}

- (void)setDeleteButtonShown:(BOOL)deleteButtonShown {
    _deleteButtonShown = deleteButtonShown;
    self.deleteButton.hidden = !deleteButtonShown;
}


@end
