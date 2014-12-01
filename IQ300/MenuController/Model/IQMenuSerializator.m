//
//  IQMenuSerializator.m
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQMenuSerializator.h"
#import "IQMenuSection.h"
#import "IQMenuItem.h"

@implementation IQMenuSerializator

+ (NSArray*)serializeMenuFromList:(NSString*)pList error:(NSError**)error {
    NSString * pListPath = [[NSBundle localizedBundle] pathForResource:pList ofType:@"plist"];
    NSArray * sections = [[NSArray alloc] initWithContentsOfFile:pListPath];
    NSMutableArray * menuSections = [NSMutableArray array];
    
    for (NSDictionary * section in sections) {
        IQMenuSection * menuSection = [[IQMenuSection alloc] init];
        menuSection.sectionId = section[@"sectionId"];
        menuSection.title = section[@"title"];
        menuSection.isExpandable = [section[@"isExpandable"] boolValue];
        
        for (NSDictionary * item in section[@"items"]) {
            IQMenuItem * menuItem = [[IQMenuItem alloc] init];
            [menuItem setValuesForKeysWithDictionary:item];
            [menuSection addItem:menuItem];
        }
        
        [menuSections addObject:menuSection];
    }
    
    return [menuSections copy];
}

@end
