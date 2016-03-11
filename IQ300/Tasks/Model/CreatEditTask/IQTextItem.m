//
//  IQTextItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTextItem.h"

@implementation IQTextItem

- (instancetype)initWithText:(NSString *)text {
    return [self initWithText:text placeholder:nil];
}

- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder {
    return [self initWithText:text placeholder:placeholder editable:NO];
}

- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder editable:(BOOL)editable {
    self = [super initWithString:text];
    if (self) {
        _placeholder = placeholder;
        _editable = editable;
    }
    return self;
}

- (void)setText:(NSString *)text {
    self.string = text;
}

- (NSString *)text {
    return self.string;
}

@end
