//
//  TaskComplexityCell.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "TaskComplexityCell.h"
#import "IQComplexity.h"

@implementation TaskComplexityCell

@dynamic item;

+ (CGFloat)heightForItem:(IQComplexity*)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * text = item.displayName;
    return [IQDetailsTextCell heightForItem:text detailTitle:detailTitle width:width];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleTextView.placeholderColor = [UIColor blackColor];
    }
    return self;
}

- (void)setItem:(IQComplexity *)item {
    [super setItem:item];
    
    if (item) {
        self.titleTextView.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Complexity", nil), item.displayName];
    }
}

@end
