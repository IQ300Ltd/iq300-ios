//
//  TaskDescriptionController.m
//  IQ300
//
//  Created by Tayphoon on 16.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskDescriptionController.h"
#import "DispatchAfterExecution.h"

#define SEPARATOR_HEIGHT 0.5f
#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xcccccc]
#define BOTTOM_VIEW_HEIGHT 65

@interface TaskDescriptionController() <UITextViewDelegate> {
    CGFloat _textViewBottomMarging;
}

@end

@implementation TaskDescriptionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Description", nil);
        _textViewInsets = UIEdgeInsetsMakeWithInset(15.0f);
    }
    return self;
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _textView = [[PlaceholderTextView alloc] init];
    [_textView setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
    [_textView setTextColor:[UIColor colorWithHexInt:0x20272a]];
    _textView.textAlignment = NSTextAlignmentLeft;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    _textView.textContainerInset = UIEdgeInsetsZero;
    _textView.contentInset = UIEdgeInsetsZero;
    _textView.text = self.fieldValue;
    _textView.placeholderInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
    _textView.delegate = self;
    [self.view addSubview:_textView];

    _bottomSeparatorView = [[UIView alloc] init];
    [_bottomSeparatorView setBackgroundColor:SEPARATOR_COLOR];
    [self.view addSubview:_bottomSeparatorView];
    
    _doneButton = [[ExtendedButton alloc] init];
    _doneButton.layer.cornerRadius = 4.0f;
    _doneButton.layer.borderWidth = 0.5f;
    [_doneButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [_doneButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
    [_doneButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
    _doneButton.layer.borderColor = _doneButton.backgroundColor.CGColor;
    [_doneButton setClipsToBounds:YES];
    [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self layoutTextView];
}

#pragma mark - Keyboard Notifications

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO
                                      notification:notification];
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:YES
                                      notification:notification];
}

- (void)onKeyboardDidShow:(NSNotification *)notification {
    _textView.selectedRange = NSMakeRange(_textView.text.length, 0);
}

#pragma mark - Private methods

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat inset = MIN(keyboardRect.size.height, keyboardRect.size.width);
    _textViewBottomMarging = down ? 0 : inset;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self layoutTextView];
    
    [UIView commitAnimations];
}

- (void)layoutTextView {
    CGRect actualBounds = self.view.bounds;
    actualBounds.size.height = actualBounds.size.height - BOTTOM_VIEW_HEIGHT - _textViewBottomMarging;
    
    _bottomSeparatorView.frame = CGRectMake(self.view.bounds.origin.x,
                                            self.view.bounds.origin.y + self.view.bounds.size.height - BOTTOM_VIEW_HEIGHT - _textViewBottomMarging,
                                            self.view.bounds.size.width,
                                            SEPARATOR_HEIGHT);
    
    CGSize doneButtonSize = CGSizeMake(300, 40);
    _doneButton.frame = CGRectMake(self.view.bounds.origin.x + (self.view.bounds.size.width - doneButtonSize.width) / 2.0f,
                                   self.view.bounds.origin.y + self.view.bounds.size.height - doneButtonSize.height - 10.0f - _textViewBottomMarging,
                                   doneButtonSize.width,
                                   doneButtonSize.height);

    CGRect textViewRect = UIEdgeInsetsInsetRect(actualBounds, _textViewInsets);
    _textView.frame = textViewRect;
}

- (void)backButtonAction:(UIButton*)sender {
    [_textView resignFirstResponder];
    NSString * oldDescription = ([self.fieldValue length] > 0) ? self.fieldValue : @"";
    if (![oldDescription isEqualToString:_textView.text]) {
        dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
            [UIAlertView showWithTitle:NSLocalizedString(@"Attention", nil)
                               message:NSLocalizedString(@"Save changes?", nil)
                     cancelButtonTitle:NSLocalizedString(@"Сancellation", nil)
                     otherButtonTitles:@[NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil)]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == 1 || buttonIndex == 2) {
                                      if (buttonIndex == 1) {
                                          [self saveChanges];
                                      }
                                      [self.navigationController popViewControllerAnimated:YES];
                                  }
                              }];
        });
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonAction:(UIButton*)sender {
    [_textView resignFirstResponder];
    [self saveChanges];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveChanges {
    if ([self.fieldValue isEqualToString:_textView.text] == NO &&
        [self.delegate respondsToSelector:@selector(taskFieldEditController:didChangeFieldValue:)]) {
        [self.delegate taskFieldEditController:self didChangeFieldValue:_textView.text];
    }
}

@end
