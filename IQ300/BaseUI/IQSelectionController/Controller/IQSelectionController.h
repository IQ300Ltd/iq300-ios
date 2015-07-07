//
//  IQFieldSelectionControllerViewController.h
//  IQ300
//
//  Created by Tayphoon on 24.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "IQSelectionControllerModel.h"

@class IQSelectionController;
@protocol IQSelectionControllerDelegate <NSObject>

@optional

- (void)selectionControllerController:(IQSelectionController*)controller didSelectItem:(id)item;

@end


@interface IQSelectionController : IQTableBaseController

@property (nonatomic, strong) id<IQTableModel, IQSelectionControllerModel> model;
@property (nonatomic, weak)   id delegate;

@end
