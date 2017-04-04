//
//  UsersPickerModel.m
//  IQ300
//
//  Created by Tayphoon on 10.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "UsersPickerModel.h"
#import "ContactCell.h"
#import "IQSession.h"
#import "IQService.h"
#import "IQChannel.h"
#import "IQNotificationCenter.h"
#import "IQUser.h"

static NSString * UReuseIdentifier = @"UReuseIdentifier";

@interface UsersPickerModel() {
    NSArray * _usersInternal;
    NSArray * _usersWithAll;
    
    __weak id _userStatusChangedObserver;
    NSString *_currentUserStatusChangedChannelName;
}

@end

@implementation UsersPickerModel

- (id)init {
    self = [super init];
    if (self) {
        _sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]];
    }
    return self;
}

- (void)setUsers:(NSArray *)users {
    _users = users;
    
    AllUsersObject *allUsersObject = [[AllUsersObject alloc] init];
    _usersWithAll = [users arrayByAddingObject:allUsersObject];
    
    [self updateModelWithCompletion:^(NSError *error) {
        [self modelDidChanged];
    }];
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSString*)titleForSection:(NSInteger)section {
    return nil;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
    return (section == 0) ? [_usersInternal count] : 0;
}

- (NSString*)reuseIdentifierForIndexPath:(NSIndexPath*)indexPath {
    return UReuseIdentifier;
}

- (UITableViewCell*)createCellForIndexPath:(NSIndexPath*)indexPath {
    Class cellClass = [ContactCell class];
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleSubtitle
                            reuseIdentifier:UReuseIdentifier];
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath*)indexPath {
    return 68;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section == 0 &&
       indexPath.row < _usersInternal.count) {
        return [_usersInternal objectAtIndex:indexPath.row];
    }
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
    NSInteger index = [_usersInternal indexOfObject:object];
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
    return nil;
}

- (Class)controllerClassForItemAtIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)updateModelWithCompletion:(void (^)(NSError * error))completion {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId != %@", [IQSession defaultSession].userId];
    
    if([_filter length] > 0) {
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"(displayName CONTAINS[cd] %@) OR (email CONTAINS[cd] %@)", _filter, _filter];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, filterPredicate]];
    }
    
    _usersInternal = [[_usersWithAll filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:self.sortDescriptors];
    
    if(completion) {
        completion(nil);
    }
    [self subscribeToUserNotifications];
}

- (void)clearModelData {
    _users = nil;
    _usersInternal = nil;
    _usersWithAll = nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
    [self modelWillChangeContent];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    [self modelDidChangeSectionAtIndex:sectionIndex
                         forChangeType:type];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    [self modelDidChangeObject:anObject
                   atIndexPath:indexPath
                 forChangeType:type
                  newIndexPath:newIndexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
    [self modelDidChangeContent];
}

#pragma mark - Delegate methods

- (void)modelWillChangeContent {
    if ([self.delegate respondsToSelector:@selector(modelWillChangeContent:)]) {
        [self.delegate modelWillChangeContent:self];
    }
}

- (void)modelDidChangeSectionAtIndex:(NSUInteger)sectionIndex forChangeType:(NSInteger)type {
    if ([self.delegate respondsToSelector:@selector(model:didChangeSectionAtIndex:forChangeType:)]) {
        [self.delegate model:self didChangeSectionAtIndex:sectionIndex forChangeType:type];
    }
}

- (void)modelDidChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSInteger)type newIndexPath:(NSIndexPath *)newIndexPath {
    if ([self.delegate respondsToSelector:@selector(model:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate model:self didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

- (void)modelDidChangeContent {
    if ([self.delegate respondsToSelector:@selector(modelDidChangeContent:)]) {
        [self.delegate modelDidChangeContent:self];
    }
}

- (void)modelDidChanged {
    if([self.delegate respondsToSelector:@selector(modelDidChanged:)]) {
        [self.delegate modelDidChanged:self];
    }
}

- (void)modelCountersDidChanged {
    if([self.delegate respondsToSelector:@selector(modelCountersDidChanged:)]) {
        [self.delegate modelCountersDidChanged:self];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unsubscribeToUserStatusChangedNotification];
}

#pragma mark - User subscrtiptions

- (void)subscribeToUserNotifications {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *indexes = [_usersInternal valueForKey:@"userId"];
        if (indexes && indexes.count) {
            [[IQService sharedService] subscribeToUserStatusChangedNotification:indexes
                                                                        handler:^(BOOL success,  IQChannel *channel, NSData *responseData, NSError *error) {
                                                                            [self resubscribeToUserStatusChangedNotificationWithChannel:channel.name];
                                                                        }];
        }
        else {
            [self resubscribeToUserStatusChangedNotificationWithChannel:nil];
        }
    });
}

- (void)resubscribeToUserStatusChangedNotificationWithChannel:(NSString *)channel {
    [self unsubscribeToUserStatusChangedNotification];
    
    if (channel && channel.length > 0) {
        __weak typeof(self) weakSelf = self;
        void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
            [weakSelf modelWillChangeContent];
            
            NSArray *onlineUserIndexes = [notf.userInfo[IQNotificationDataKey] objectForKey:@"online_ids"];
            NSArray *offlineUserIndexes = [notf.userInfo[IQNotificationDataKey] objectForKey:@"offline_ids"];
            
            NSArray *onlineUsers = [_usersInternal filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId IN %@", onlineUserIndexes]];
            
            for (IQUser *user in onlineUsers) {
                user.online = @(YES);
                NSIndexPath *indexPath = [self indexPathOfObject:user];
                [self modelDidChangeObject:user atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
            }
            
            NSArray *offlineUsers = [_usersInternal filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId IN %@", offlineUserIndexes]];
            
            for (IQUser *user in offlineUsers) {
                user.online = @(NO);
                NSIndexPath *indexPath = [self indexPathOfObject:user];
                [self modelDidChangeObject:user atIndexPath:indexPath forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
            }
            
            [[IQService sharedService].context saveToPersistentStore:nil];
            [weakSelf modelDidChangeContent];
        };
        
        _userStatusChangedObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQUserDidChangeStatusNotification
                                                                                  channelName:channel
                                                                                        queue:nil
                                                                                   usingBlock:block];
    }
    
    _currentUserStatusChangedChannelName = channel;
}

- (void)unsubscribeToUserStatusChangedNotification {
    if (_userStatusChangedObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_userStatusChangedObserver];
    }
}

@end

@implementation AllUsersObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _email = @"All";
        _displayName = NSLocalizedString(_email, nil);
        _userId = @(NSIntegerMin);
        _online = @(NO);
    }
    return self;
}

@end
