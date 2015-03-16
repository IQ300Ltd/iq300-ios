//
//  ExpandableTableView.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExpandableTableViewDataSource <UITableViewDataSource>

@optional

- (BOOL)tableView:(UITableView *)tableView canExpandSection:(NSInteger)section;
- (BOOL)tableView:(UITableView *)tableView isSectionExpanded:(NSInteger)section;

@end

@protocol ExpandableTableViewDelegate <UITableViewDelegate>

@optional

- (void)tableView:(UITableView *)tableView willExpandSection:(NSUInteger)section animated:(BOOL)animated;
- (void)tableView:(UITableView *)tableView didExpandSection:(NSUInteger)section animated:(BOOL)animated;

- (void)tableView:(UITableView *)tableView willCollapseSection:(NSUInteger)section animated:(BOOL)animated;
- (void)tableView:(UITableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated;

@end

@interface ExpandableTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) NSIndexSet * expandedSections;

@property (nonatomic, assign)   id <ExpandableTableViewDataSource> dataSource;
@property (nonatomic, assign)   id <ExpandableTableViewDelegate>   delegate;

- (void)collapseSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)expandSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)animation;
- (void)expandCollapseSection:(NSInteger)section animated:(BOOL)animated;

@end
