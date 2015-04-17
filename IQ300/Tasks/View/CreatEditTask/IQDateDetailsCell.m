//
//  IQDateDetailsCell.m
//  IQ300
//
//  Created by Tayphoon on 17.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQDateDetailsCell.h"
#import "NSDate+IQFormater.h"

@implementation IQDateDetailsCell

@dynamic item;

+ (CGFloat)heightForItem:(NSDate*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * dateFormat = @"dd.MM.yyyy HH:mm";
    NSString * text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(detailTitle, nil),
                                                            [item dateToStringWithFormat:dateFormat]];
    
    return [IQDetailsTextCell heightForItem:text detailTitle:detailTitle width:width];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        _accessoryImageView.image = [UIImage imageNamed:@"calendar_accessory_image.png"];
    }
    
    return self;
}

- (void)setItem:(NSDate*)date {
    [super setItem:date];
    
    if (date) {
        NSString * dateFormat = @"dd.MM.yyyy HH:mm";
        self.titleTextView.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(self.detailTitle, nil),
                                                                        [date dateToStringWithFormat:dateFormat]];
    }
}

@end
