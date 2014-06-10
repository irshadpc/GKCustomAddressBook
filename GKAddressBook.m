//
//  ABAddressBook.m
//  GKContactExchange
//
//  Created by Georg Kitz on 6/25/12.
//  Copyright (c) 2012 Georg Kitz. All rights reserved.
//

#import "GKAddressBook.h"
#import "GKGroup.h"
#import "GKContact.h"

@implementation GKAddressBook{
    
    NSArray *_allContacts;
    NSArray *_allContactsSorted;
    NSArray *_allGroups;
    
    ABAddressBookRef _addressBookRef;
}

#pragma mark -
#pragma mark Init

- (id)init{
    if (self = [super init]) {
        CFErrorRef error = NULL;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
        _addressBookRef = ABAddressBookCreate();
#else
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
#endif
        
        if (error) {
            NSLog(@"Couldnot create GKAddressBook, Error %@", error);
            return nil;
        }
    }
    return self;
}

- (id)initWithAddressBookRef:(ABAddressBookRef)addressBookRef
{
    if (addressBookRef == nil) {
        return nil;
    }
    
    if (self = [super init]) {
        _addressBookRef = CFRetain(addressBookRef);
    }
    
    return self;
}

#pragma mark -
#pragma mark Public

- (NSArray *)allContacts
{
    if (_allContacts) {
        return _allContacts;
    }
    
    NSArray *allContacts = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(_addressBookRef));
    NSMutableArray *people = [[NSMutableArray alloc] initWithCapacity:[allContacts count]];
    
    for (id record in allContacts) {
        ABAddressBookRef item = (__bridge ABAddressBookRef)(record);
        GKContact *contact = [[GKContact alloc] initWithABRecordRef:item];
        
        [people addObject:contact];
    }
    
    _allContacts = [[NSArray alloc] initWithArray:people];
    return _allContacts;
}

- (NSArray *)allContactsSorted
{
    if (_allContactsSorted) {
        return _allContactsSorted;
    }
    
    CFArrayRef peopleRef = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    CFMutableArrayRef peopleMutableRef = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(peopleRef), peopleRef);
    
    
    CFArraySortValues(peopleMutableRef,
                      CFRangeMake(0, CFArrayGetCount(peopleMutableRef)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      (void*) kABPersonSortByFirstName
                      );
    
    NSArray *allContacts = (__bridge NSArray *)(peopleMutableRef);
    NSMutableArray *people = [[NSMutableArray alloc] initWithCapacity:[allContacts count]];
    
    for (id record in allContacts) {
        ABAddressBookRef item = (__bridge ABAddressBookRef)(record);
        NSMutableArray *userEmails = [NSMutableArray new];
        ABMutableMultiValueRef multi = ABRecordCopyValue(item, kABPersonEmailProperty);
        if (ABMultiValueGetCount(multi) > 0) {
            // collect all emails in array
            for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
                CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multi, i);
                [userEmails addObject:(__bridge id)(emailRef)];
                CFRelease(emailRef);
            }
        }
        CFRelease(multi);
        
        if ([userEmails count]>0) {
            GKContact *contact = [[GKContact alloc] initWithABRecordRef:item];
            [people addObject:contact];
        }
        
    }
    
    
    _allContactsSorted = [[NSArray alloc] initWithArray:people];
    return _allContactsSorted;
}

- (NSArray *)allGroups
{
    if (_allGroups) {
        return _allGroups;
    }
    
    NSArray *allGroups = (__bridge NSArray *) ABAddressBookCopyArrayOfAllGroups( _addressBookRef );
    NSMutableArray *groups = [[NSMutableArray alloc] initWithCapacity:[allGroups count]];
    for (id record in allGroups) {
        ABAddressBookRef item = (__bridge ABAddressBookRef)(record);
        GKGroup *contact = [[GKGroup alloc] initWithABRecordRef:item];
        [groups addObject:contact];
    }
    
    _allGroups = [[NSArray alloc] initWithArray:groups];
    return _allGroups;
}

- (NSArray *)filterForContactWithArray:(NSArray *)filterEmails
{
	NSArray *contacts = [self allContactsSorted];
    NSMutableArray *filteredContacts = [NSMutableArray new];
    
    for (GKContact *contact in contacts) {
        for (NSString *email in filterEmails) {
            if ([[contact email] isEqualToString:email]) {
                contact.isSelected = YES;
            } else if ([contact email] && !contact.isSelected) {
                contact.isSelected = NO;
            }
        }
        [filteredContacts addObject:contact];
        //NSLog(@"%@ %@",contact.name,[NSNumber numberWithBool:contact.isSelected]);
    }
    
    return filteredContacts;
}

#pragma mark -
#pragma mark Memory Managment

- (void)dealloc
{
    if (_addressBookRef) {
        CFRelease(_addressBookRef);
    }
}

@end
