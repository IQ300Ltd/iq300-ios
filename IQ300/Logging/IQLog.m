//
//  IQLog.m
//  IQ 300
//
//  Created by Tayphoon on 29.07.13.
//
//

#import "IQLog.h"

@interface IQLog : NSObject

@end

@implementation IQLog

+ (void)load
{
    lcl_configure_by_name("*", lcl_vTrace);
}

@end
