//
//  ContactPickerController.m
//  IQ300
//
//  Created by Tayphoon on 20.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "ContactPickerController.h"
#import "IQContact.h"

@interface ContactPickerController ()

@end

@implementation ContactPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQContact * contact = [self.model itemAtIndexPath:indexPath];
    
    if([self.delegate respondsToSelector:@selector(contactPickerController:didPickUser:)]) {
        [self.delegate contactPickerController:self didPickUser:contact.user];
    }
}

@end
