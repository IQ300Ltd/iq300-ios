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
#define CELL_MIN_HEIGHT 50.0f

@interface IQEditableTextCell : UITableViewCell {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) id item;
@property (nonatomic, strong) NSString * detailTitle;
@property (nonatomic, readonly) PlaceholderTextView * titleTextView;
@property (nonatomic, getter = isEnabled) BOOL enabled;

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end
