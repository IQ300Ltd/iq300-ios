//
//  IQTextCell.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQItemCellProtocol.h"
#import "PlaceholderTextView.h"

#define TEXT_COLOR [UIColor colorWithHexInt:0x272727]
#define CONTENT_VERTICAL_INSETS 12
#define CONTENT_HORIZONTAL_INSETS 13
#define CELL_MIN_HEIGHT 50.0f

#ifdef IPAD
#define TEXT_FONT [UIFont fontWithName:IQ_HELVETICA size:14]
#else
#define TEXT_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#endif

@class IQTextItem;

@protocol IQTextCellDelegate;

@interface IQTextCell : UITableViewCell <IQItemCellProtocol> {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong, readonly) PlaceholderTextView *textView;
@property (nonatomic, strong, readonly) UIImageView *accessoryImageView;

@property (nonatomic, weak) id<IQTextCellDelegate> delegate;

+ (CGFloat)heightForItem:(IQTextItem *)item width:(CGFloat)width;

- (void)setItem:(IQTextItem *)item;

- (CGFloat)heightForWidth:(CGFloat)width;

@end

@protocol IQTextCellDelegate <NSObject>

@optional
- (BOOL)textCell:(IQTextCell *)cell textViewShouldBeginEditing:(UITextView *)textView;
- (BOOL)textCell:(IQTextCell *)cell textViewShouldEndEditing:(UITextView *)textView;

- (void)textCell:(IQTextCell *)cell textViewDidBeginEditing:(UITextView *)textView;
- (void)textCell:(IQTextCell *)cell textViewDidEndEditing:(UITextView *)textView;

- (BOOL)textCell:(IQTextCell *)cell textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textCell:(IQTextCell *)cell textViewDidChange:(UITextView *)textView;

- (void)textCell:(IQTextCell *)cell textViewDidChangeSelection:(UITextView *)textView;

- (BOOL)textCell:(IQTextCell *)cell textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange;
- (BOOL)textCell:(IQTextCell *)cell textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange;

@end
