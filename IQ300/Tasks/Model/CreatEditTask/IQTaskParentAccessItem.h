//
//  IQParentAccessItem.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 22/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTextItem.h"
#import "IQTaskItemProtocol.h"

@interface IQTaskParentAccessItem : IQTextItem<IQTaskItemProtocol>

@property (nonatomic, assign, readonly) BOOL selected;

@end
