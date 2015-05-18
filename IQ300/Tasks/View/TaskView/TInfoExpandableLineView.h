//
//  TInfoExpandableLineView.h
//  IQ300
//
//  Created by Tayphoon on 28.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TInfoLineView.h"

@interface TInfoExpandableLineView : TInfoLineView

@property (nonatomic, readonly) UITextView * detailsTextLabel;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

- (void)setActionBlock:(void (^)(TInfoExpandableLineView * view))block;

@end
