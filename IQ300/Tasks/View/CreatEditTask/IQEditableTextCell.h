//
//  IQEditableTextCell.h
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "PlaceholderTextView.h"

#define TEXT_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#define TEXT_COLOR [UIColor colorWithHexInt:0x272727]
#define CONTENT_VERTICAL_INSETS 12
#define CONTENT_HORIZONTAL_INSETS 13

@interface IQEditableTextCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, readonly) PlaceholderTextView * titleTextView;

+ (CGFloat)heightForItem:(NSString*)text width:(CGFloat)width;

@end
