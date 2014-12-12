//
//  MessagesView.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExTextField.h"

@interface MessagesView : UIView

@property (nonatomic, strong) ExTextField * searchBar;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UILabel * noDataLabel;

@end
