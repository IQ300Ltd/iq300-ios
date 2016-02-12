//
//  TCCollectionCell.h
//  White Collared
//
//  Created by Tayphoon on 04.02.16.
//  Copyright © 2016 Proarise. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCCollectionCell <NSObject>

@property (nonatomic, strong) id item;

+ (CGFloat)heightForItem:(id)item constrainedToSize:(CGSize)size;

@end
