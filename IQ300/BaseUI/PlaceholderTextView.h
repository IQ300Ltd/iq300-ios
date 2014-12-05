//
//  PlaceholderTextView.h
//  IQ300
//
//  Created by Tayphoon on 23.12.11.
//  Copyright (c) 2011 Tayphoon. All rights reserved.
//

/**
 UITextView subclass that adds placeholder support like UITextField has.
 */
@interface PlaceholderTextView : UITextView

/**
 The string that is displayed when there is no other text in the text view.
 
 The default value is `nil`.
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 The color of the placeholder.
 
 The default is `[UIColor lightGrayColor]`.
 */
@property (nonatomic, strong) UIColor * placeholderColor;
@property (nonatomic, strong) UIFont * placeholderFont;
@property (nonatomic, assign) UIEdgeInsets placeholderInsets;

@end
