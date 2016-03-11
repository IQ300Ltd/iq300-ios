//
//  IQMultipleCellsCell.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQItemCellProtocol.h"

@protocol IQMultipleCellsCellDelegate;

@interface IQMultipleCellsCell : UITableViewCell

@property (nonatomic, strong, readonly) NSArray *cells;
@property (nonatomic, strong, readonly) NSArray *separators;

@property (nonatomic, weak) id<IQMultipleCellsCellDelegate> delegate;

+ (CGFloat)heightForItem:(NSArray <__kindof IQItem *> *)item cellClasses:(NSArray< __kindof Class<IQItemCellProtocol> > *)cells width:(CGFloat)width;

+ (NSString *)reuseIdentifierForCellClasses:(NSArray< __kindof Class >*)cells;

- (instancetype)initWithStyle:(UITableViewCellStyle)style cellClassess:(NSArray< __kindof Class<IQItemCellProtocol> > *)cells;

- (void)setItem:(NSArray <__kindof IQItem *> *)item;

@end

@protocol IQMultipleCellsCellDelegate <NSObject>

- (void)multipleCellsCell:(IQMultipleCellsCell *)cell didSelectSubcellAtIndex:(NSUInteger)index;

@end