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
#import "IQManagedAttachment.h"
#import "PhotoViewController.h"
#import "DownloadManager.h"
#import "UIViewController+ScreenActivityIndicator.h"
#import "ALAsset+Extension.h"
#import "IQBadgeIndicatorView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "TaskPolicyInspector.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "IQSession.h"
#import "IQService.h"
#import "DispatchAfterExecution.h"
#import "IQActivityViewController.h"
#import "SharingAttachment.h"

#define COLLECTION_INSET 15.0f

@interface TDocumentsController () <IQActivityViewControllerDelegate> {
    TaskAttachmentsModel * _attachmentsModel;
    UICollectionView *_collectionView;
    UIDocumentInteractionController * _documentController;
#ifdef IPAD
    UIPopoverController *_popoverController;
#endif
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
            [self.model reloadModelSourceControllerWithCompletion:^(NSError *error) {
                [self.collectionView reloadData];
            }];
        }
    }
}

- (void)setPolicyInspector:(TaskPolicyInspector *)policyInspector {
    _policyInspector = policyInspector;
    [self updateInterfaceFoPolicies];
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
    
    [self.collectionView registerClass:[TAttachmentCell class]
            forCellWithReuseIdentifier:[self.model reuseIdentifierForCellAtIndexPath:[NSIndexPath indexPathForItem:0
                                                                                                         inSection:0]]];

    [self setActivityIndicatorBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3f]];
    [self setActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    [self.noDataLabel setText:NSLocalizedString(@"No attachments", nil)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskPolicyDidChanged:)
                                                 name:IQTaskPolicyDidChangedNotification
                                               object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [self proccessServiceError:error];
             [[weakSelf.collectionView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
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
    
    self.model.resetReadFlagAutomatically = YES;
    [self.model resetReadFlagWithCompletion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    self.model.resetReadFlagAutomatically = NO;
}

- (UICollectionView*)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout * collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        [collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(COLLECTION_INSET, COLLECTION_INSET, COLLECTION_INSET, COLLECTION_INSET)];
        [collectionViewFlowLayout setMinimumInteritemSpacing:COLLECTION_INSET];
        [collectionViewFlowLayout setMinimumLineSpacing:COLLECTION_INSET];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:collectionViewFlowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.bounces = YES;
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}


#pragma mark - UICollectionView DataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TAttachmentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self.model reuseIdentifierForCellAtIndexPath:indexPath]
                                                                            forIndexPath:indexPath];
    [cell setItem:[self.model itemAtIndexPath:indexPath]];
    return cell;
}

#pragma mark - UICollectionView Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.policyInspector isActionAvailable:@"read" inCategory:self.category];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    IQManagedAttachment * attachment = [self.model itemAtIndexPath:indexPath];
    TAttachmentCell * cell = (TAttachmentCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect rectForAppearing = [cell.superview convertRect:cell.frame toView:self.view];
    if([attachment.contentType rangeOfString:@"image"].location != NSNotFound &&
       [attachment.originalURL length] > 0) {
        PhotoViewController * controller = [[PhotoViewController alloc] init];
        controller.imageURL = [NSURL URLWithString:attachment.originalURL];
        controller.fileName = attachment.displayName;
        controller.contentType = attachment.contentType;
        controller.previewURL = [NSURL URLWithString:attachment.previewURL];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ([attachment.localURL length] > 0) {
        [self showActivityViewControllerAttachment:attachment fromRect:rectForAppearing];
    }
    else {
        [self showActivityIndicator];
        [[DownloadManager sharedManager] downloadDataFromURL:attachment.originalURL
                                                    MIMEType:attachment.contentType
                                                     success:^(NSOperation *operation, NSURL * storedURL, NSData *responseData) {
                                                         attachment.localURL = storedURL.path;
                                                         
                                                         NSError *saveError = nil;
                                                         if(![attachment.managedObjectContext saveToPersistentStore:&saveError] ) {
                                                             NSLog(@"Save attachment error: %@", saveError);
                                                         }
                                                         [self showActivityViewControllerAttachment:attachment fromRect:rectForAppearing];
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
    [self.collectionView setContentOffset:CGPointZero animated:NO];

    __weak typeof(self) weakSelf = self;
    [self.model addAttachmentWithAsset:asset
                              fileName:[asset fileName]
                        attachmentType:[asset MIMEType]
                            completion:^(NSError *error) {
                                if (error) {
                                    if(IsNetworUnreachableError(error) || ![IQService sharedService].isServiceReachable) {
                                        [weakSelf showHudWindowWithText:NSLocalizedString(INTERNET_UNREACHABLE_MESSAGE, nil)];
                                    }
                                    else {
                                        [weakSelf showErrorAlertWithMessage:NSLocalizedString(@"Failed add document to task", nil)];
                                    }
                                }
                                [weakSelf hideActivityIndicator];
                            }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)modelCountersDidChanged:(TaskAttachmentsModel*)model {
    self.tabBarItem.badgeValue = BadgTextFromInteger([self.model.unreadCount integerValue]);
}

#pragma mark - Activity indicator overrides

- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.collectionView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:NO];
    
    [super showActivityIndicatorAnimated:YES completion:nil];
}

- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [super hideActivityIndicatorAnimated:YES completion:^{
        [self.collectionView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:YES];
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Private methods

- (void)updateModel {
    if([IQSession defaultSession]) {
        [self showActivityIndicatorAnimated:YES completion:nil];
        [self.model updateModelWithCompletion:^(NSError *updateError) {
            dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)applicationWillEnterForeground {
    if([IQSession defaultSession]) {
        [self updateModel];
        
        if (self.model.resetReadFlagAutomatically) {
            [self.model resetReadFlagWithCompletion:nil];
        }
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

- (void)showActivityViewControllerAttachment:(IQManagedAttachment *)attachment fromRect:(CGRect)rect {
    [self hideActivityIndicator];
    
    IQActivityViewController *controller = [[IQActivityViewController alloc] initWithAttachment:[[SharingAttachment alloc] initWithPath:attachment.localURL
                                                                                                                            displayName:attachment.displayName
                                                                                                                            contentType:attachment.contentType]];
    NSMutableArray *excludedActivityes = [[NSMutableArray alloc] init];
    [excludedActivityes addObject:UIActivityTypeSaveToCameraRoll];
    if (![attachment.contentType hasPrefix:@"video"]) {
        [excludedActivityes addObject:IQActivityTypeSaveVideo];
    }
    controller.excludedActivityTypes = [excludedActivityes copy];
    controller.delegate = self;
    controller.documentInteractionControllerRect = rect;
    
#ifdef IPAD
    UIPopoverPresentationController *popoverController = [controller popoverPresentationController];
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverController.sourceView = self.view;
    popoverController.sourceRect = rect;
#endif
    
    [self presentViewController:controller animated:YES completion:nil];
}

#ifdef IPAD
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _popoverController = nil;
}
#endif

#pragma mark - Policies methods

- (void)taskPolicyDidChanged:(NSNotification*)notification {
    if (notification.object == _policyInspector && [self isVisible]) {
        [self updateInterfaceFoPolicies];
        [self.collectionView reloadData];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IQActivityViewControllerDelegate

- (BOOL)willShowDocumentInteractionController {
    return YES;
}
- (void)shouldShowDocumentInteractionController:(UIDocumentInteractionController * _Nonnull)controller fromRect:(CGRect)rect{
    _documentController = controller;
    [_documentController setDelegate:(id<UIDocumentInteractionControllerDelegate>)self];
    if(![_documentController presentOpenInMenuFromRect:rect inView:self.view animated:YES]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                           message:NSLocalizedString(@"You do not have an application installed to view files of this type", nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

#pragma mark - UIDocumentInteractionController Delegate Methods

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return  self;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    _documentController = nil;
}

@end
