//
//  IQComplexityEstimatedTimeDoubleCell.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 09/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQComplexityEstimatedTimeDoubleCell.h"
#import "IQComplexity.h"


@interface IQComplexityEstimatedTimeDoubleCell()

@property (nonatomic, strong) IQComplexity *complexity;
@property (nonatomic, strong) NSNumber *estimatedTime;

@end

@implementation IQComplexityEstimatedTimeDoubleCell

+ (CGFloat)heightForComplexity:(IQComplexity *)compexity estimatedTime:(NSNumber *)esimatedTime widht:(CGFloat)widht {
    CGFloat taskComplexityHeight = [TaskComplexityCell heightForItem:compexity detailTitle:nil width:widht/2.0f];
    CGFloat estimatedTimeHeight = [TaskEstimatedTimeCell heightForItem:esimatedTime detailTitle:nil width:widht/2.0f];
    return MAX(taskComplexityHeight, estimatedTimeHeight);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _complexityCell = [[TaskComplexityCell alloc] initWithStyle:style reuseIdentifier:nil];
        _estimatedCell = [[TaskEstimatedTimeCell alloc] initWithStyle:style reuseIdentifier:nil];
        
        [self addSubview:_complexityCell];
        [self addSubview:_estimatedCell];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat widht = self.bounds.size.width / 2.0f;
    
    CGFloat taskComplexityHeight = [TaskComplexityCell heightForItem:_complexity detailTitle:nil width:widht/2.0f];
    CGFloat estimatedTimeHeight = [TaskEstimatedTimeCell heightForItem:_estimatedTime detailTitle:nil width:widht/2.0f];
    
    CGFloat height = self.bounds.size.height;
    
    _complexityCell.frame = CGRectMake(0.0f, (height - taskComplexityHeight) / 2.0f, widht, taskComplexityHeight);
    _estimatedCell.frame = CGRectMake(widht, (height - taskComplexityHeight) / 2.0f, widht, estimatedTimeHeight);
}

- (void)setComplexity:(IQComplexity *)complexity estimatedTime:(NSNumber *)estimatedTime {
    _complexity = complexity;
    _estimatedTime = estimatedTime;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_complexityCell prepareForReuse];
    [_estimatedCell prepareForReuse];
}

@end
