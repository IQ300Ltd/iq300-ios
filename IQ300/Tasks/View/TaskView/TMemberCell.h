//
//  TMemberCell.h
//  IQ300
//
//  Created by Tayphoon on 25.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

@class IQTaskMember;

@interface TMemberCell : SWTableViewCell

@property (nonatomic, strong) IQTaskMember * item;
@property (nonatomic, strong) NSArray * availableActions;

@end
