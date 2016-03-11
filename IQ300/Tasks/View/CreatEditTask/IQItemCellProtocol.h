//
//  IQItemCellProtocol.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQItem;

@protocol IQItemCellProtocol <NSObject>

+ (CGFloat)heightForItem:(IQItem *)item width:(CGFloat)width;

- (void)setItem:(IQItem *)item;
- (CGFloat)heightForWidth:(CGFloat)width;

@end
