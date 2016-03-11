//
//  IQMultipleCellsCell.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQMultipleCellsCell.h"

#define SEPARATOR_COLOR [UIColor colorWithHexInt:0xc0c0c0]
#define SEPARATOR_WIDHT 0.5f

@interface IQMultipleCellsCell ()

@property (nonatomic, strong) NSArray *gestures;

@end

@implementation IQMultipleCellsCell

+ (CGFloat)heightForItem:(NSArray<__kindof IQItem *> *)item cellClasses:(NSArray<__kindof Class<IQItemCellProtocol>> *)cells width:(CGFloat)width {
    NSAssert(item.count == cells.count, @"Wrong items count");
    CGFloat height = 0;
    CGFloat itemWidht = (width - SEPARATOR_WIDHT * cells.count - 1)/ cells.count;
    for (NSUInteger i = 0; i < item.count; ++i) {
        height = MAX(height, [[cells objectAtIndex:i] heightForItem:[item objectAtIndex:i] width:itemWidht]);
    }
    return height;
}

+ (NSString *)reuseIdentifierForCellClasses:(NSArray<__kindof Class> *)cells {
    NSMutableString *reuseIdentifier = [[NSMutableString alloc] initWithString:NSStringFromClass([self class])];
    for (Class class in cells) {
        [reuseIdentifier appendString:NSStringFromClass(class)];
    }
    return reuseIdentifier;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style cellClassess:(NSArray<__kindof Class> *)cells {
    self = [super initWithStyle:style reuseIdentifier:[IQMultipleCellsCell reuseIdentifierForCellClasses:cells]];
    if (self) {
        NSMutableArray *mutableCells = [[NSMutableArray alloc] initWithCapacity:cells.count];
        NSMutableArray *mutableSeparators = [[NSMutableArray alloc] initWithCapacity:cells.count - 1];
        NSMutableArray *mutableGestures = [[NSMutableArray alloc] initWithCapacity:cells.count];\
        
        for (Class class in cells) {
            UITableViewCell *cell = [[class alloc] initWithStyle:style reuseIdentifier:nil];
            [mutableCells addObject:cell];
            [self.contentView addSubview:cell];
            
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [cell addGestureRecognizer:gesture];
            [mutableGestures addObject:gesture];
            
            if (mutableSeparators.count < cells.count - 1) {
                CALayer *layer = [[CALayer alloc] init];
                layer.backgroundColor = SEPARATOR_COLOR.CGColor;
                [mutableSeparators addObject:layer];
                [self.layer addSublayer:layer];
            }
        }
        _cells = [mutableCells copy];
        _separators = [mutableSeparators copy];
        _gestures = [mutableGestures copy];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    CGSize itemSize = CGSizeMake((size.width - SEPARATOR_WIDHT * _separators.count)/ _cells.count, size.height);
    
    CGFloat xPosition = 0.0f;
    CGFloat xStep = itemSize.width + SEPARATOR_WIDHT;
    
    for (UITableViewCell *cell in _cells) {
        cell.frame = CGRectMake(xPosition, 0.0f, itemSize.width, itemSize.height);
        xPosition+= xStep;
    }
    
    xPosition = itemSize.width;
    for (CALayer *layer in _separators) {
        layer.frame = CGRectMake(xPosition, 0.0f, SEPARATOR_WIDHT, size.height);
    }
    
}

- (void)setItem:(NSArray <__kindof IQItem *> *)item {
    NSAssert([item isKindOfClass:[NSArray class]], @"NSArray expected");
    NSArray *items = (NSArray *)item;

    NSAssert(items.count == _cells.count, @"Wrong items count");
    
    for (NSUInteger i = 0; i < items.count; i++) {
        [[_cells objectAtIndex:i] setItem:[items objectAtIndex:i]];
    }
}

- (void)tapAction:(id)sender {
    if (_delegate) {
        NSUInteger index = [_gestures indexOfObject:sender];
        NSAssert(index != NSNotFound, @"Gesture not found. Something strange");
        [_delegate multipleCellsCell:self didSelectSubcellAtIndex:index];
    }
}

@end
