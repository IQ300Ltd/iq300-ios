//
//  IQTextView.m
//  IQ300
//
//  Created by Tayphoon on 10.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTextView.h"

@implementation IQTextView

- (instancetype)initWithFrame:(CGRect)frame {
    IQLayoutManager *manager = [IQLayoutManager new];
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(frame.size.width, FLT_MAX)];
    container.widthTracksTextView = YES;
    container.heightTracksTextView = NO;
    [manager addTextContainer:container];
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    [storage addLayoutManager:manager];
    
    self = [super initWithFrame:frame textContainer:container];
    if (self) {
    }
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    IQLayoutManager *manager = [IQLayoutManager new];
    
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:self.textContainer.size];
    container.widthTracksTextView = self.textContainer.widthTracksTextView;
    container.heightTracksTextView = self.textContainer.heightTracksTextView;
    
    [manager addTextContainer:container];
    
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    [storage addLayoutManager:manager];
    
    IQTextView *replacement = [[[self class] alloc] initWithFrame:self.frame textContainer:container];
    replacement.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Copy over constraints
    NSMutableArray *constraintBuffer = [NSMutableArray array];
    for (NSLayoutConstraint *c in self.constraints) {
        [constraintBuffer addObject:[replacement translatedConstraintFor:c originalObject:self]];
    }
    [self removeConstraints:self.constraints];
    [replacement addConstraints:constraintBuffer];
    
    replacement.backgroundColor = self.backgroundColor;
    
    replacement.font = self.font;
    
    replacement.clearsOnInsertion = NO;
    replacement.selectable = self.selectable;
    replacement.editable = self.editable;
    
    replacement.textAlignment = self.textAlignment;
    replacement.textColor = self.textColor;
    replacement.autocapitalizationType = self.autocapitalizationType;
    replacement.autocorrectionType = self.autocorrectionType;
    replacement.spellCheckingType = self.spellCheckingType;
    return replacement;
}

- (NSLayoutConstraint *)translatedConstraintFor:(NSLayoutConstraint *)constraint originalObject:(id)original {
    if (constraint.firstItem == original) {
        return [NSLayoutConstraint constraintWithItem:self
                                            attribute:constraint.firstAttribute
                                            relatedBy:constraint.relation
                                               toItem:constraint.secondItem
                                            attribute:constraint.secondAttribute
                                           multiplier:constraint.multiplier
                                             constant:constraint.constant];
    }
    else if (constraint.secondItem == original) {
        return [NSLayoutConstraint constraintWithItem:constraint.firstItem
                                            attribute:constraint.firstAttribute
                                            relatedBy:constraint.relation
                                               toItem:self
                                            attribute:constraint.secondAttribute
                                           multiplier:constraint.multiplier
                                             constant:constraint.constant];
    }
    else {
        return constraint;
    }
}

@end
