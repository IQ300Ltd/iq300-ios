//
//  TMembersController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/CALayer.h>

#import "TMembersController.h"
#import "ContactPickerController.h"
#import "IQSession.h"
#import "ContactCell.h"
#import "IQUser.h"
#import "IQTaskMember.h"
#import "IQTask.h"
#import "DiscussionController.h"
#import "MessagesModel.h"
#import "IQConversation.h"
#import "IQBadgeView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "UIScrollView+PullToRefreshInsert.h"

@interface TMembersController () <ContactPickerControllerDelegate> {
    UILabel * _noDataLabel;
}

@end

@implementation TMembersController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Members", nil);

        UIImage * barImage = [[UIImage imageNamed:@"task_member_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeFrameColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0x338cae];
        style.badgeFrame = YES;
        
        IQBadgeView * badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        badgeView.badgeMinSize = 15;
        badgeView.frameLineHeight = 1.0f;
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:9];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(37.5f, 3.5f);

        self.model = [[TaskMembersModel alloc] init];
    }
    return self;
}

- (void)setTaskId:(NSNumber *)taskId {
    if(![_taskId isEqualToNumber:taskId]) {
        _taskId = taskId;
        
        self.model.taskId = taskId;
        
        if(self.isViewLoaded) {
            [self reloadModel];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf reloadDataWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    _noDataLabel = [[UILabel alloc] init];
    [_noDataLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
    [_noDataLabel setTextColor:[UIColor colorWithHexInt:0xb3b3b3]];
    _noDataLabel.textAlignment = NSTextAlignmentCenter;
    _noDataLabel.backgroundColor = [UIColor clearColor];
    _noDataLabel.numberOfLines = 0;
    _noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_noDataLabel setHidden:YES];
    [_noDataLabel setText:NSLocalizedString(@"No contacts", nil)];
    [self.view addSubview:_noDataLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white_add_ico.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(addButtonAction:)];
    self.parentViewController.navigationItem.rightBarButtonItem = addButton;
    
    [self reloadModel];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQTaskMember * member = [self.model itemAtIndexPath:indexPath];
    
    cell.textLabel.text = member.user.displayName;
    cell.detailTextLabel.numberOfLines = 0;

    UIFont * font = [UIFont fontWithName:IQ_HELVETICA size:13];
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.maximumLineHeight = 1000;
    paragraphStyle.minimumLineHeight = 3;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.lineSpacing = 3.0f;
    
    NSMutableDictionary * attributes = @{
                                         NSParagraphStyleAttributeName  : paragraphStyle,
                                         NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x9f9f9f],
                                         NSFontAttributeName            : font
                                         }.mutableCopy ;
    
    NSMutableAttributedString * detailText = [[NSMutableAttributedString alloc] initWithString:member.user.email
                                                                                    attributes:attributes];
    
    [attributes setValue:[UIFont fontWithName:IQ_HELVETICA size:10] forKey:NSFontAttributeName];
    [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", member.taskRoleName]
                                                                       attributes:attributes]];
    cell.detailTextLabel.attributedText = detailText;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQTaskMember * member = [self.model itemAtIndexPath:indexPath];
    NSString * companionName = member.user.displayName;
    NSNumber * userId = member.user.userId;
    [MessagesModel createConversationWithRecipientId:userId
                                          completion:^(IQConversation * conv, NSError *error) {
                                              if(!error) {
                                                  DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conv.discussion];
                                                  model.companionId = userId;
                                                  
                                                  DiscussionController * controller = [[DiscussionController alloc] init];
                                                  controller.hidesBottomBarWhenPushed = YES;
                                                  controller.model = model;
                                                  controller.title = companionName;
                                                  
                                                  [MessagesModel markConversationAsRead:conv completion:nil];
                                                  [self.navigationController pushViewController:controller animated:YES];
                                              }
                                          }];
}

#pragma mark - IQTableModel Delegate

- (void)modelDidChangeContent:(id<IQTableModel>)model {
    [super modelDidChangeContent:model];
    [self updateNoDataLabelVisibility];
}

- (void)modelDidChanged:(id<IQTableModel>)model {
    [super modelDidChanged:model];
    [self updateNoDataLabelVisibility];
}

#pragma mark - ContactPickerController Delegate

- (void)contactPickerController:(ContactPickerController *)picker didPickUser:(IQUser *)user {
    [self.model addMemberWithUserId:user.userId completion:^(NSError *error) {
        
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)addButtonAction:(UIButton*)sender {
    NSArray * users = [self.model.members valueForKey:@"user"];
    
    ContactPickerController * controller = [[ContactPickerController alloc] init];
    controller.model = [[UsersModel alloc] init];
    controller.model.excludeUserIds = [users valueForKey:@"userId"];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateNoDataLabelVisibility {
    [_noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)reloadModel {
    if([IQSession defaultSession]) {
        [self reloadDataWithCompletion:^(NSError *error) {
            [self updateNoDataLabelVisibility];
        }];
    }
}

@end
