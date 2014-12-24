//
//  ArrayTransformer.m
//  OBI
//
//  Created by Tayphoon on 21.08.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "ArrayTransformer.h"

@implementation ArrayTransformer

+ (Class)transformedValueClass
{
    return [NSArray class];
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
