//
//  IQStringItem.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 09/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQItem.h"

@interface IQStringItem : IQItem

@property (nonatomic, strong) NSString *string;

- (instancetype)initWithString:(NSString *)string;

@end
