//
//  OrderedArrayTransformer.m
//  IQ300
//
//  Created by Tayphoon on 28.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "OrderedArrayTransformer.h"

@implementation OrderedArrayTransformer

+ (Class)transformedValueClass
{
    return [NSOrderedSet class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
