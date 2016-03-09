//
//  IQAttachment.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 02/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQAttachment <NSObject>

@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * originalURL;
@property (nonatomic, strong) NSString * localURL;
@property (nonatomic, strong) NSString * previewURL;
@property (nonatomic, strong) NSString * contentType;

@end

@interface IQAttachment : NSObject <IQAttachment>

@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * originalURL;
@property (nonatomic, strong) NSString * localURL;
@property (nonatomic, strong) NSString * previewURL;
@property (nonatomic, strong) NSString * contentType;

@end
