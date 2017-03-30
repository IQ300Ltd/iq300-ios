//
//  IQEditableTextCell.h
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "PlaceholderTextView.h"
#import "IQTableCell.h"

#define TEXT_COLOR IQ_FONT_BLACK_COLOR
#define CONTENT_VERTICAL_INSETS 12
#define CONTENT_HORIZONTAL_INSETS 13
#define CELL_MIN_HEIGHT 50.0f

#ifdef IPAD
#define TEXT_FONT [UIFont fontWithName:IQ_HELVETICA size:14]
#else
#define TEXT_FONT [UIFont fontWithName:IQ_HELVETICA size:13]
#endif

@interface IQEditableTextCell : UITableViewCell<IQTableCell> {
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong) id item;
@property (nonatomic, strong) NSString * detailTitle;
@property (nonatomic, readonly) PlaceholderTextView * titleTextView;
@property (nonatomic, getter = isEnabled) BOOL enabled;

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end
