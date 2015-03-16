//
//  UsersPickerModel.h
//  IQ300
//
//  Created by Tayphoon on 10.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface UsersPickerModel : NSObject<IQTableModel>

@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) NSString * filter;
@property (strong, nonatomic) NSArray  * sortDescriptors;

@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

@end
