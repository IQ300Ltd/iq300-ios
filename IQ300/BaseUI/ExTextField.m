//
//  ExTextField.m
//  IQ300
//
//  Created by Tayphoon on 14.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "ExTextField.h"

@implementation ExTextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.placeholderInsets);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.textInsets);
}

@end
