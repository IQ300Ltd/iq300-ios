//
//  IQEMultiLineTextCell.m
//  IQ300
//
//  Created by Tayphoon on 01.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQEMultiLineTextCell.h"

@implementation IQEMultiLineTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.titleTextView.returnKeyType = UIReturnKeyDefault;
        
#ifndef IPAD
        CGFloat toolWidth = [UIScreen mainScreen].bounds.size.width;
        UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, toolWidth, 30)];
        UIBarButtonItem * flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:nil
                                                                                        action:nil];
        UIImage * keyboardImage = [[UIImage imageNamed:@"hide_keyboard_ico.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem * hideKeyboardButton = [[UIBarButtonItem alloc] initWithImage:keyboardImage
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self.titleTextView
                                                                               action:@selector(resignFirstResponder)];
        [toolbar setItems:@[flexibleSpace, hideKeyboardButton]];
        self.titleTextView.inputAccessoryView = toolbar;
#endif
    }
    
    return self;
}

@end
