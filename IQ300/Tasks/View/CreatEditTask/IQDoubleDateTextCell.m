//
//  IQDoubleDateTextCell.m
//  IQ300
//
//  Created by Tayphoon on 19.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQDoubleDateTextCell.h"
#import "NSDate+IQFormater.h"

@implementation IQDoubleDateTextCell

@dynamic item;

+ (CGFloat)heightForItem:(NSDate*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
//    NSString * dateFormat = @"dd.MM.yyyy HH:mm";
//    NSString * text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(detailTitle, nil),
//                       [item dateToStringWithFormat:dateFormat]];
    
    return [IQDoubleDetailsTextCell heightForItem:item detailTitle:detailTitle width:width];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        _accessoryImageView.image = [UIImage imageNamed:@"calendar_accessory_image.png"];
        _secondAccessoryImageView.image = [UIImage imageNamed:@"calendar_accessory_image.png"];
    }
    
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    _accessoryImageView.image = (self.enabled) ? [UIImage imageNamed:@"calendar_accessory_image.png"] : nil;
}

- (void)setSecondEnabled:(BOOL)enabled {
    [super setSecondEnabled:enabled];
    
    _secondAccessoryImageView.image = (self.enabled) ? [UIImage imageNamed:@"calendar_accessory_image.png"] : nil;
}

- (void)setItem:(NSArray*)dates {
    [super setItem:dates];
    
    if ([dates count] >= 2 && [dates[0] isKindOfClass:[NSDate class]] &&
        [dates[1] isKindOfClass:[NSDate class]]) {
        NSString * dateFormat = @"dd.MM.yyyy HH:mm";
        self.titleTextView.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(self.detailTitle, nil),
                                                                        [dates[0] dateToStringWithFormat:dateFormat]];
        self.secondTitleTextView.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(self.secondDetailTitle, nil),
                                                                              [dates[1] dateToStringWithFormat:dateFormat]];
    }
}

@end
