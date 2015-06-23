//
//  TDocumentsController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <CTAssetsPickerController/CTAssetsPickerController.h>

#import "TDocumentsController.h"
#import "IQTask.h"
#import "TAttachmentCell.h"
#import "IQAttachment.h"
#import "PhotoViewController.h"
#import "DownloadManager.h"
#import "UIViewController+ScreenActivityIndicator.h"
#import "ALAsset+Extension.h"
#import "IQBadgeIndicatorView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "TaskPolicyInspector.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "IQSession.h"

@interface TDocumentsController () {
    TaskAttachmentsModel * _attachmentsModel;
    UIDocumentInteractionController * _documentController;
}

@end

@implementation TDocumentsController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Documents", nil);

        UIImage * barImage = [[UIImage imageNamed:@"task_documents_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeIndicatorView * badgeView = [[IQBadgeIndicatorView alloc] init];
        badgeView.badgeColor = [UIColor colorWithHexInt:0xe74545];
        badgeView.strokeBadgeColor = [UIColor whiteColor];
        badgeView.frame = CGRectMake(0, 0, 9.0f, 9.0f);
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(2.5f, 10.5f);

        _attachmentsModel = [[TaskAttachmentsModel alloc] init];
        _attachmentsModel.section = 0;
        self.model = _attachmentsModel;
    }
    return self;
}

- (NSString*)category {
    return @"documents";
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

- (void)setBadgeValue:(NSNumber *)badgeValue {
    if(!self.model.resetReadFlagAutomatically) {
        self.tabBarItem.badgeValue = BadgTextFromInteger([badgeValue integerValue]);
    }
}

- (NSNumber*)badgeValue {
    return @([self.tabBarItem.badgeValue integerValue]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];

    [self setActivityIndicatorBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f]];
    [self setActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    [self.noDataLabel setText:NSLocalizedString(@"No attachments", nil)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskPolicyDidChanged:)
                                                 name:IQTaskPolicyDidChangedNotification
                                               object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf reloadDataWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [self updateInterfaceFoPolicies];
    [self reloadModel];
    
    self.model.resetReadFlagAutomatically = YES;
    [self.model resetReadFlagWithCompletion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    self.model.resetReadFlagAutomatically = NO;
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TAttachmentCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    cell.item = [self.model itemAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Enable or disable view attachments
    if([self.policyInspector isActionAvailable:@"read" inCategory:self.category]) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQAttachment * attachment = [self.model itemAtIndexPath:indexPath];
    TAttachmentCell * cell = (TAttachmentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    CGRect rectForAppearing = [cell.superview convertRect:cell.frame toView:self.view];
    if([attachment.contentType rangeOfString:@"image"].location != NSNotFound &&
       [attachment.originalURL length] > 0) {
        PhotoViewController * controller = [[PhotoViewController alloc] init];
        controller.imageURL = [NSURL URLWithString:attachment.originalURL];
        controller.fileName = attachment.displayName;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ([attachment.localURL length] > 0) {
        [self showOpenInForURL:attachment.localURL fromRect:rectForAppearing];
    }
    else {
        [self showActivityIndicator];
        NSArray * urlComponents = [attachment.originalURL componentsSeparatedByString:@"?"];
        NSString * fileExtension = [[urlComponents firstObject] pathExtension];
        [[DownloadManager sharedManager] downloadDataFromURL:attachment.originalURL
                                                     success:^(NSOperation *operation, NSString * storedURL, NSData *responseData) {
                                                         NSString * destinationURL = [storedURL stringByAppendingPathExtension:fileExtension];
                                                         [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:storedURL]
                                                                                                 toURL:[NSURL fileURLWithPath:destinationURL]
                                                                                                 error:nil];
                                                         attachment.localURL = destinationURL;
                                                         
                                                         NSError *saveError = nil;
                                                         if(![attachment.managedObjectContext saveToPersistentStore:&saveError] ) {
                                                             NSLog(@"Save attachment error: %@", saveError);
                                                         }
                                                         [self showOpenInForURL:destinationURL fromRect:rectForAppearing];
                                                     }
                                                     failure:^(NSOperation *operation, NSError *error) {
                                                         [self hideActivityIndicator];
                                                     }];
    }
}

#pragma mark - Assets Picker Delegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group {
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupAll);
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset {
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    return YES;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didSelectAsset:(ALAsset *)asset {
    [self showActivityIndicator];
    
    __weak typeof(self) weakSelf = self;
    [self.model addAttachmentWithAsset:asset
                              fileName:[asset fileName]
                        attachmentType:[asset MIMEType]
                            completion:^(NSError *error) {
                                if (error) {
                                    [UIAlertView showWithTitle:@"IQ300"
                                                       message:NSLocalizedString(@"Failed add document to task", nil)
                                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                             otherButtonTitles:nil
                                                      tapBlock:nil];
                                }
                                [weakSelf hideActivityIndicator];
                            }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIDocumentInteractionController Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    _documentController = nil;
}

#pragma mark - IQTableModel Delegate

- (void)modelCountersDidChanged:(TaskAttachmentsModel*)model {
    self.tabBarItem.badgeValue = BadgTextFromInteger([self.model.unreadCount integerValue]);
}

#pragma mark - Private methods

- (void)reloadModel {
    if([IQSession defaultSession]) {
        [self reloadDataWithCompletion:^(NSError *error) {
            [self updateNoDataLabelVisibility];
        }];
    }
}

- (void)addButtonAction:(UIButton*)sender {
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allAssets];
    picker.showsCancelButton = YES;
    picker.delegate = (id<CTAssetsPickerControllerDelegate>)self;
    picker.showsNumberOfAssets = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showOpenInForURL:(NSString*)localURL fromRect:(CGRect)rect {
    [self hideActivityIndicator];
    NSURL * documentURL = [NSURL fileURLWithPath:localURL isDirectory:NO];
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:documentURL];
    [_documentController setDelegate:(id<UIDocumentInteractionControllerDelegate>)self];
    if(![_documentController presentOpenInMenuFromRect:rect inView:self.view animated:YES]) {
        [UIAlertView showWithTitle:@"IQ300" message:NSLocalizedString(@"You do not have an application installed to view files of this type", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

#pragma mark - Policies methods

- (void)taskPolicyDidChanged:(NSNotification*)notification {
    if (notification.object == _policyInspector && [self isVisible]) {
        [self updateInterfaceFoPolicies];
        [self.tableView reloadData];
    }
}

- (void)updateInterfaceFoPolicies {
    if([self.policyInspector isActionAvailable:@"create" inCategory:self.category]) {
        UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white_add_ico.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(addButtonAction:)];
        self.parentViewController.navigationItem.rightBarButtonItem = addButton;
    }
    else {
        self.parentViewController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)applicationWillEnterForeground {
    [self.model updateModelWithCompletion:nil];
    if (self.model.resetReadFlagAutomatically) {
        [self.model resetReadFlagWithCompletion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
