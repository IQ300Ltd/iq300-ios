//
//  MenuSectionHeader.h
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuSectionHeader : UIView {
    void (^_actionBlock)(MenuSectionHeader* header);
}

@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSInteger section;

- (void)setActionBlock:(void (^)(MenuSectionHeader* header))block;
- (void)setSelected:(BOOL)selected;
- (void)setExpandable:(BOOL)expandable;

@end
