//
//  TAttachmentCell.m
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TAttachmentCell.h"
#import "IQAttachment.h"

#define CONTEN_BACKGROUND_COLOR [UIColor whiteColor]
#define CONTEN_BACKGROUND_COLOR_HIGHLIGHTED [UIColor colorWithHexInt:0xe9faff]
#define NEW_FLAG_COLOR [UIColor colorWithHexInt:0x005275]
#define NEW_FLAG_WIDTH 4.0f

@implementation TAttachmentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        _contentBackgroundInsets = UIEdgeInsetsZero;
        [self setBackgroundColor:NEW_FLAG_COLOR];
        
        _contentBackgroundView = [[UIView alloc] init];
        _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
        [self.contentView addSubview:_contentBackgroundView];

        UIImage * attachImage = [UIImage imageNamed:@"attach_ico.png"];
        self.imageView.image = attachImage;
        self.imageView.backgroundColor = CONTEN_BACKGROUND_COLOR;

        self.textLabel.numberOfLines = 3;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textLabel.backgroundColor = CONTEN_BACKGROUND_COLOR;
        
    }
    return self;
}

- (void)setItem:(IQAttachment *)item {
    _item = item;
    
    NSDictionary *underlineAttribute = @{
                                         NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:11],
                                         NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle),
                                         NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x358bae]
                                         };
    [self.textLabel setAttributedText:[[NSAttributedString alloc] initWithString:item.displayName
                                                                      attributes:underlineAttribute]];
    BOOL unread = [_item.unread boolValue];
    _contentBackgroundView.backgroundColor = (unread) ? CONTEN_BACKGROUND_COLOR_HIGHLIGHTED :
                                                        CONTEN_BACKGROUND_COLOR;
    _contentBackgroundInsets = UIEdgeInsetsMake(0, (unread) ? NEW_FLAG_WIDTH : 0, 0, 0);
    self.imageView.backgroundColor = _contentBackgroundView.backgroundColor;
    self.textLabel.backgroundColor = _contentBackgroundView.backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect contentBackgroundBounds = UIEdgeInsetsInsetRect(self.contentView.bounds, _contentBackgroundInsets);
    _contentBackgroundView.frame = contentBackgroundBounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _contentBackgroundInsets = UIEdgeInsetsZero;
    _contentBackgroundView.backgroundColor = CONTEN_BACKGROUND_COLOR;
    self.imageView.backgroundColor = CONTEN_BACKGROUND_COLOR;
    self.textLabel.backgroundColor = CONTEN_BACKGROUND_COLOR;
}

@end
