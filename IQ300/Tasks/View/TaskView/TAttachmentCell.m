//
//  TAttachmentCell.m
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TAttachmentCell.h"
#import "IQAttachment.h"

@implementation TAttachmentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        UIImage * attachImage = [UIImage imageNamed:@"attach_ico.png"];
        self.imageView.image = attachImage;
        
        self.textLabel.numberOfLines = 3;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
}

@end
