//
//  TInfoLineView.h
//  IQ300
//
//  Created by Tayphoon on 18.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@interface TInfoLineView : BottomLineView {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) UIImageView * imageView;
@property (nonatomic, readonly) UILabel     * textLabel;
@property (nonatomic, assign)   CGSize      imageViewSize;
@property (nonatomic, assign)   BOOL drawLeftSeparator;
@property (nonatomic, assign)   BOOL drawTopSeparator;

- (CGFloat)heightConstrainedToSize:(CGSize)size;

@end
