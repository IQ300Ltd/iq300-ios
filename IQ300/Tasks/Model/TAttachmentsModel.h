//
//  TAttachmentsModel.h
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface TAttachmentsModel : NSObject<IQTableModel>

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) NSArray * items;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

@end
