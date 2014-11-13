//
//  MTableHeaderView.h
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@interface MTableHeaderView : BottomLineView {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) NSString * title;

@end
