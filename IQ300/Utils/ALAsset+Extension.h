//
//  ALAsset+Extension.h
//  IQ300
//
//  Created by Tayphoon on 08.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Extension)

@property (nonatomic, readonly) NSString * MIMEType;
@property (nonatomic, readonly) NSString * fileName;

@end
