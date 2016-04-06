//
//  IQChannel.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 06/04/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <Foundation/Foundation.h>

@interface IQChannel : NSObject

@property (nonatomic, strong) NSString *name;

+ (RKObjectMapping*)objectMapping;

@end
