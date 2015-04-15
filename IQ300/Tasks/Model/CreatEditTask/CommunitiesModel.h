//
//  CommunitiesModel.h
//  IQ300
//
//  Created by Tayphoon on 15.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface CommunitiesModel : IQTableModel

@property (nonatomic, strong) NSNumber * communityId;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) NSIndexPath * selectedIndexPath;

- (BOOL)isItemSelectedAtIndexPath:(NSIndexPath*)indexPath;

@end
