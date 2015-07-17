//
//  ConferenceInfoModel.m
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>
#import <RestKit/RestKit.h>

#import "ConferenceInfoModel.h"
#import "IQConversationMember.h"
#import "IQEditableTextCell.h"
#import "ContactInfoCell.h"
#import "IQConversationMember.h"
#import "IQService+Messages.h"
#import "IQUser.h"

#import "IQConversation.h"
#import "IQDiscussion.h"
#import "IQComment.h"
#import "NSManagedObject+ActiveRecord.h"

@interface NSObject(UserModelCells)

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width;

@end

static NSString * EditReuseIdentifier = @"EditReuseIdentifier";
static NSString * UserReuseIdentifier = @"UserReuseIdentifier";

@interface ConferenceInfoModel() {
    NSArray * _admins;
    NSMutableArray * _members;
    BOOL _isAdministrator;
}

@end

@implementation ConferenceInfoModel

- (id)init {
    self = [super init];
    if(self) {
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.sortDescriptors = @[descriptor];
    }
    return self;
}

- (void)setConversation:(IQConversation *)conversation {
    _conversation = conversation;
    _conversationTitle = conversation.title;
}

- (NSArray*)users {
    return [_members copy];
}

- (BOOL)isAdministrator {
    return _isAdministrator;
}

- (Class)cellClassForIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return [IQEditableTextCell class];
    }
    
    return [ContactInfoCell class];
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return (indexPath.section == 0 && indexPath.row == 0) ? EditReuseIdentifier : UserReuseIdentifier;
}

- (NSUInteger)numberOfSections {
    return 3;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return (section == 1) ? [_admins count] : [_members count];
}

- (NSString*)titleForSection:(NSInteger)section {
    return (section == 1) ? NSLocalizedString(@"Group administrator:", nil) :
                            NSLocalizedString(@"Group members:", nil);
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    BOOL isEditCellPath = (indexPath.section == 0 && indexPath.row == 0);
    Class cellClass = (isEditCellPath) ? [IQEditableTextCell class] : [ContactInfoCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:[self reuseIdentifierForIndexPath:indexPath]];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassForIndexPath:indexPath];
    
    NSString * detaiTitle = NSLocalizedString(@"", nil);
    id item = [self itemAtIndexPath:indexPath];
    if (cellClass) {
        return [cellClass heightForItem:item detailTitle:detaiTitle width:self.cellWidth];
    }
    return 50.0f;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section < [self numberOfSections] &&
       indexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return self.conversationTitle;
        }
        else if(indexPath.section == 1) {
            return _admins[indexPath.row];
        }
        else {
            return [_members objectAtIndex:indexPath.row];
        }
    }
    return nil;
}

- (NSString*)placeholderForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0 && indexPath.row == 0) ? NSLocalizedString(@"Group name", nil) : nil;
}

- (BOOL)isDeleteEnableForForItemAtIndexPath:(NSIndexPath*)indexPath {
    return (_isAdministrator && indexPath.section != 1);
}

- (void)updateModelWithCompletion:(void (^)(NSError *))completion {
    [[IQService sharedService] membersForConversation:self.conversation.conversationId
                                              handler:^(BOOL success, NSArray * members, NSData *responseData, NSError *error) {
                                                  if (success) {
                                                      _members = [[members sortedArrayUsingDescriptors:self.sortDescriptors] mutableCopy];
                                                      NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isAdministrator == YES "];
                                                      NSArray * admins = [_members filteredArrayUsingPredicate:predicate];
                                                      _admins = admins;
                                                      
                                                      if ([admins count] > 0) {
                                                          [_members removeObjectsInArray:admins];
                                                          
                                                          IQConversationMember * admin = [_admins firstObject];
                                                          if ([IQSession defaultSession].userId) {
                                                              _isAdministrator = [admin.userId isEqualToNumber:[IQSession defaultSession].userId];
                                                          }
                                                          else {
                                                              _isAdministrator = NO;
                                                          }
                                                      }
                                                  }
                                                  
                                                  if (completion) {
                                                      completion(error);
                                                  }
                                              }];
}

- (void)updateTitle:(NSString *)title {
    self.conversationTitle = title;
}

- (void)saveConversationTitleWithCompletion:(void (^)(NSError *))completion {
    [[IQService sharedService] updateConversationTitle:self.conversationTitle
                                        conversationId:self.conversation.conversationId
                                               handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                   if (success) {
                                                       [self updateConversationWithTitle:self.conversationTitle];
                                                       
                                                       [self modelWillChangeContent];
                                                       [self modelDidChangeObject:nil
                                                                      atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                    forChangeType:NSFetchedResultsChangeUpdate
                                                                     newIndexPath:nil];
                                                       [self modelDidChangeContent];
                                                   }
                                                   
                                                   if (completion) {
                                                       completion(error);
                                                   }
                                               }];
}

- (void)updateConversationWithTitle:(NSString *)title {
    self.conversation.title = title;
    
    NSError *__autoreleasing saveError = nil;
    if(![self.conversation.managedObjectContext saveToPersistentStore:&saveError]) {
        NSLog(@"Failed save to presistent store conversation with new title");
    }
}

- (void)addMembersFromUsers:(NSArray*)users completion:(void (^)(NSError *))completion {
    NSArray * userIds = [users valueForKey:@"userId"];
    [[IQService sharedService] addMembersWithIds:userIds
                                  toConversation:self.conversation.conversationId
                                         handler:^(BOOL success, NSData *responseData, NSError *error) {
                                             if (success) {
                                                 [self wrapUsersToMemebers:users];
                                                 
                                                 [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                           action:GAIAddConversationMemberEventAction
                                                                            label:[userIds componentsJoinedByString:@", "]];
                                             }
                                             
                                             if (completion) {
                                                 completion(error);
                                             }
                                         }];
}

- (void)removeMember:(IQConversationMember*)member completion:(void (^)(NSError *))completion {
    if ([_members containsObject:member]) {
        [[IQService sharedService] removeMemberWithId:member.userId
                                     fromConversation:self.conversation.conversationId
                                              handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                  if (success) {
                                                      NSUInteger index = [_members indexOfObject:member];
                                                      [_members removeObjectAtIndex:index];
                                                      
                                                      [self modelWillChangeContent];
                                                      [self modelDidChangeObject:nil
                                                                     atIndexPath:[NSIndexPath indexPathForRow:index inSection:2]
                                                                   forChangeType:NSFetchedResultsChangeDelete
                                                                    newIndexPath:nil];
                                                      [self modelDidChangeContent];
                                                  }
                                                  if (completion) {
                                                      completion(error);
                                                  }
                                              }];
    }
}

- (void)leaveConversationWithCompletion:(void (^)(NSError *))completion {
    [[IQService sharedService] leaveConversationWithId:self.conversation.conversationId
                                               handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                   if (success) {
                                                       [GAIService sendEventForCategory:GAIMessagesEventCategory
                                                                                 action:@"event_action_conversation_leave"
                                                                                  label:[self.conversation.conversationId stringValue]];
                                                   }
                                                   if(completion) {
                                                       completion(error);
                                                   }
                                               }];
}

#pragma mark - Private methods

- (void)wrapUsersToMemebers:(NSArray*)users {
    for (IQUser * user in users) {
        IQConversationMember * memeber = [IQConversationMember meberFromUser:user];
        [_members addObject:memeber];
    }
    
    [_members sortUsingDescriptors:self.sortDescriptors];
}



- (void)removeConversation {
    [self.conversation removeLocalConversation];
}

@end
