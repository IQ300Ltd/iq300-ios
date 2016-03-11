//
//  FeedbackController.m
//  IQ300
//
//  Created by Tayphoon on 23.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <CTAssetsPickerController/CTAssetsPickerController.h>

#import "CreateFeedbackController.h"
#import "IQDetailsTextCell.h"
#import "ExtendedButton.h"
#import "FeedbackCategoriesModel.h"
#import "FeedbackTypesModel.h"
#import "IQSelectionController.h"
#import "DispatchAfterExecution.h"
#import "FeedbackAttachmentsCell.h"
#import "UIActionSheet+Blocks.h"
#import "FileStore.h"
#import "UIViewController+ScreenActivityIndicator.h"

#define BOTTOM_VIEW_HEIGHT 0

@interface CreateFeedbackController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    CGFloat _tableBottomMarging;
    NSIndexPath * _editableIndexPath;
    FeedbackCategoriesModel * _categoriesModel;
    FeedbackTypesModel * _typesModel;
    
    CGPoint _tableContentOffset;
}

@end

@implementation CreateFeedbackController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _tableBottomMarging = BOTTOM_VIEW_HEIGHT;
        
        _categoriesModel = [[FeedbackCategoriesModel alloc] init];
        _typesModel = [[FeedbackTypesModel alloc] init];
        
        self.title = NSLocalizedString(@"New feedback", nil);
    }
    
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mark_tab_item.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(sendButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutTabelView];
}

#pragma mark - UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IQEditableTextCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[FeedbackAttachmentsCell class]]) {
        FeedbackAttachmentsCell *feedbackCell = (FeedbackAttachmentsCell *)cell;
        [feedbackCell setItems:[self.model itemAtIndexPath:indexPath]];
        [feedbackCell setAddButtonShown:YES];
        [feedbackCell.addButton addTarget:self action:@selector(attachButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        NSArray *buttons = feedbackCell.buttons;
        NSUInteger tag = 0;
        for (IQAttachmentButton *button in buttons) {
            [button.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.deleteButton.tag = tag++;
        }
    }
    else {
        cell.detailTitle = [self.model detailTitleForItemAtIndexPath:indexPath];
        cell.titleTextView.placeholder = [self.model placeholderForItemAtIndexPath:indexPath];
        cell.titleTextView.delegate = (id<UITextViewDelegate>)self;
        cell.item = [self.model itemAtIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:_editableIndexPath];
    
    if ([cell isKindOfClass:[IQEditableTextCell class]]) {
        IQEditableTextCell *editableCell = (IQEditableTextCell*)cell;
        if (editableCell.titleTextView.isFirstResponder && ![indexPath isEqual:_editableIndexPath]) {
            //hide keyboard
            [editableCell.titleTextView resignFirstResponder];
        }
    }
    
    if (indexPath.row < 2) {
        IQSelectionController * controller = [self controllerForItemIndexPath:indexPath];
        controller.title = [self.model placeholderForItemAtIndexPath:indexPath];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _editableIndexPath = [self indexPathForCellChildView:textView];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [self.model updateFieldAtIndexPath:_editableIndexPath withValue:newString];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *range = textView.selectedTextRange;
    textView.text = textView.text;
    textView.selectedTextRange = range;
    [self updateCellFrameIfNeed];
}

#pragma mark - Keyboard Notifications

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO
                                      notification:notification];
    
    if (_editableIndexPath) {
        [self.tableView scrollToRowAtIndexPath:_editableIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    _editableIndexPath = nil;
    [self makeInputViewTransitionWithDownDirection:YES
                                      notification:notification];
}

#pragma mark - SelectionController delegate

- (void)selectionControllerController:(IQSelectionController*)controller didSelectItem:(id)item {
    NSIndexPath * editIndexPath = [NSIndexPath indexPathForItem:controller.view.tag inSection:0];
    [self.model updateFieldAtIndexPath:editIndexPath
                             withValue:item];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)backButtonAction:(UIButton*)sender {
    if (_editableIndexPath) {
        IQEditableTextCell * cell = (IQEditableTextCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
        [cell.titleTextView resignFirstResponder];
    }
    
    if ([self.model modelHasChanges]) {
        dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
            [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                               message:NSLocalizedString(@"Sent feedback?", nil)
                     cancelButtonTitle:NSLocalizedString(@"Сancellation", nil)
                     otherButtonTitles:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == 1 || buttonIndex == 2) {
                                      if (buttonIndex == 1) {
                                          [self sendButtonAction:self.navigationItem.rightBarButtonItem];
                                      }
                                      else {
                                          [self.navigationController popViewControllerAnimated:YES];
                                          [self.model clearModelData];
                                      }
                                  }
                              }];
        });
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
        [self.model clearModelData];
    }
}

- (void)sendButtonAction:(UIBarButtonItem *)sender {
    [self showActivityIndicator];
    if (_editableIndexPath) {
        IQEditableTextCell * cell = (IQEditableTextCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
        [cell.titleTextView resignFirstResponder];
    }

    if ([self isAllFieldsValid]) {
        dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
            [self.model createFeedbackWithCompletion:^(NSError *error) {
                [self hideActivityIndicator];
                if (!error) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [self proccessServiceError:error];
                [self.model clearModelData];
            }];
        });
    }
}

- (NSIndexPath*)indexPathForCellChildView:(UIView*)childView {
    if ([childView.superview isKindOfClass:[UITableViewCell class]] || !childView.superview) {
        UITableViewCell * cell = (UITableViewCell*)childView.superview;
        return [self.tableView indexPathForCell:cell];
    }
    
    return [self indexPathForCellChildView:childView.superview];
}

- (void)updateCellFrameIfNeed {
    IQEditableTextCell * cell = (IQEditableTextCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
    CGFloat cellHeight = [IQEditableTextCell heightForItem:cell.titleTextView.text
                                               detailTitle:cell.detailTitle
                                                     width:self.model.cellWidth];
    
    if (cell.frame.size.height != cellHeight) {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:_editableIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
    }
}

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat inset = MIN(keyboardRect.size.height, keyboardRect.size.width);
    _tableBottomMarging = down ? BOTTOM_VIEW_HEIGHT : inset;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self layoutTabelView];
    
    [UIView commitAnimations];
}

- (void)layoutTabelView {
    CGRect actualBounds = self.view.bounds;
    
    self.tableView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y,
                                      actualBounds.size.width,
                                      actualBounds.origin.y + actualBounds.size.height - _tableBottomMarging);
}

- (IQSelectionController*)controllerForItemIndexPath:(NSIndexPath*)indexPath {
    IQSelectionController * controller = [[IQSelectionController alloc] init];
    controller.model = (indexPath.row == 0) ? _typesModel : _categoriesModel;
    controller.view.tag = indexPath.row;
    return controller;
}

- (BOOL)isAllFieldsValid {
    NSError * validationError = nil;
    if (![self.model isAllFieldsValidWithError:&validationError]) {
        [self showErrorAlertWithMessage:validationError.localizedDescription];
        return NO;
    }
    return YES;
}

- (void)attachButtonAction:(UIButton*)sender {
    if (_editableIndexPath) {
        IQEditableTextCell * cell = (IQEditableTextCell*)[self.tableView cellForRowAtIndexPath:_editableIndexPath];
        [cell.titleTextView resignFirstResponder];
    }
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:NSLocalizedString(@"Take a picture", nil),
                                   NSLocalizedString(@"Photos", nil), nil];
    
    [actionSheet setDidDismissBlock:^(UIActionSheet * __nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            _tableContentOffset = self.tableView.contentOffset;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                [imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
                [imagePicker setAllowsEditing:NO];
                [imagePicker setShowsCameraControls:YES];
                [imagePicker setDelegate:self];
                imagePicker.hidesBottomBarWhenPushed = YES;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else {
                [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                                   message:NSLocalizedString(@"The camera is not available", nil)
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                  tapBlock:nil];
            }
        }
        else if (buttonIndex == 1) {
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.assetsFilter = [ALAssetsFilter allAssets];
            picker.showsCancelButton = YES;
            picker.delegate = (id<CTAssetsPickerControllerDelegate>)self;
            picker.showsNumberOfAssets = NO;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }];
    
    [actionSheet showInView:self.view];
}

- (void)deleteButtonAction:(id)sender {
    [self.model updateFieldAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] withValue:@([sender tag])];
}

#pragma mark - UIImagePickerController delegate 

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //Fix offset changed by image picker
    if (!CGPointEqualToPoint(_tableContentOffset, self.tableView.contentOffset)) {
        self.tableView.contentOffset = _tableContentOffset;
    }
    _tableContentOffset = CGPointZero;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //Fix offset changed by image picker
        if (!CGPointEqualToPoint(_tableContentOffset, self.tableView.contentOffset)) {
            self.tableView.contentOffset = _tableContentOffset;
        }
        _tableContentOffset = CGPointZero;
        
        if (image) {
            NSString * title = @"You can reduce the image size by scaling it to one of the following sizes";
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(title, nil)
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                        destructiveButtonTitle:nil
                                                             otherButtonTitles:NSLocalizedStringWithFormat(@"Small (%ld%%)", 30, nil),
                                           NSLocalizedStringWithFormat(@"Medium (%ld%%)", 50, nil),
                                           NSLocalizedStringWithFormat(@"Large (%ld%%)", 80, nil),
                                           NSLocalizedString(@"Actual", nil), nil];
            
            [actionSheet setDidDismissBlock:^(UIActionSheet * __nonnull actionSheet, NSInteger buttonIndex) {
                UIImage *attachmentImage = nil;
                if (buttonIndex <= 2) {
                    CGFloat scale = 1.0f;
                    switch (buttonIndex) {
                        case 0:
                            scale = 0.3f;
                            break;
                            
                        case 1:
                            scale = 0.5f;
                            break;
                            
                        case 2:
                            scale = 0.8f;
                            break;
                            
                        default:
                            break;
                    }
                    CGSize scaledSize = CGSizeMake(image.size.width * scale,
                                                   image.size.height * scale);
                    UIImage * scaledImage = [image imageWithFixedOrientation];
                    attachmentImage = [UIImage scaleImage:scaledImage size:scaledSize];
                }
                else if(buttonIndex != actionSheet.cancelButtonIndex) {
                    attachmentImage = [image imageWithFixedOrientation];
                }
                
                if (attachmentImage != nil) {
                    [[FileStore sharedStore] storeData:UIImageJPEGRepresentation(attachmentImage, 1.0f)
                                                forKey:[NSUUID UUID].UUIDString
                                              MIMEType:@"image/jpeg"
                                                  done:^(NSString *fileName, NSError *error) {
                                                      IQAttachment *attachment = [[IQAttachment alloc] init];
                                                      
                                                      attachment.displayName = @"IMG.jpeg";
                                                      attachment.originalURL = attachment.localURL = attachment.previewURL = [[FileStore sharedStore] filePathURLForFileName:fileName].path;
                                                      attachment.contentType = @"image/jpeg";
                                                      [self.model updateFieldAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] withValue:attachment];
                                                  }];
                }
            }];
            
            [actionSheet showInView:self.view];
        }
    }];
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
    if (asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        Byte *buffer = (Byte *)malloc((size_t)representation.size);
        NSUInteger buffered = [representation getBytes:buffer fromOffset:0 length:(NSUInteger)representation.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        NSString* MIMEType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)[representation UTI], kUTTagClassMIMEType);

        [[FileStore sharedStore] storeData:data forKey:[NSUUID UUID].UUIDString MIMEType:MIMEType done:^(NSString *fileName, NSError *error) {
            IQAttachment *attachment = [[IQAttachment alloc] init];
            
            attachment.displayName = representation.filename;
            attachment.originalURL = attachment.localURL = attachment.previewURL = [[FileStore sharedStore] filePathURLForFileName:fileName].path;
            attachment.contentType = MIMEType;
            [self.model updateFieldAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] withValue:attachment];
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
