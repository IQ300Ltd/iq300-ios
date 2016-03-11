//
//  IQTextItem.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQStringItem.h"

@interface IQTextItem : IQStringItem

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) UIReturnKeyType returnKeyType;

- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder;
- (instancetype)initWithText:(NSString *)text placeholder:(NSString *)placeholder editable:(BOOL)editable;

@end
