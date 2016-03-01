//
//  TaskComplexityModel.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface TaskComplexityModel : NSObject<IQTableModel>

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

@end
