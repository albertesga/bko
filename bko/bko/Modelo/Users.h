//
//  Users.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Likes, Message_Threads, Participants, Plans, Tickets, Unlikes;

@interface Users : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSDate * birth_date;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * surnames;
@property (nonatomic, retain) NSNumber * is_publisehd;
@property (nonatomic, retain) NSSet *user_likes;
@property (nonatomic, retain) NSSet *user_unlikes;
@property (nonatomic, retain) NSSet *user_message_threads;
@property (nonatomic, retain) NSSet *user_plan;
@property (nonatomic, retain) NSSet *user_ticket;
@property (nonatomic, retain) NSSet *user_participant;
@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addUser_likesObject:(Likes *)value;
- (void)removeUser_likesObject:(Likes *)value;
- (void)addUser_likes:(NSSet *)values;
- (void)removeUser_likes:(NSSet *)values;

- (void)addUser_unlikesObject:(Unlikes *)value;
- (void)removeUser_unlikesObject:(Unlikes *)value;
- (void)addUser_unlikes:(NSSet *)values;
- (void)removeUser_unlikes:(NSSet *)values;

- (void)addUser_message_threadsObject:(Message_Threads *)value;
- (void)removeUser_message_threadsObject:(Message_Threads *)value;
- (void)addUser_message_threads:(NSSet *)values;
- (void)removeUser_message_threads:(NSSet *)values;

- (void)addUser_planObject:(Plans *)value;
- (void)removeUser_planObject:(Plans *)value;
- (void)addUser_plan:(NSSet *)values;
- (void)removeUser_plan:(NSSet *)values;

- (void)addUser_ticketObject:(Tickets *)value;
- (void)removeUser_ticketObject:(Tickets *)value;
- (void)addUser_ticket:(NSSet *)values;
- (void)removeUser_ticket:(NSSet *)values;

- (void)addUser_participantObject:(Participants *)value;
- (void)removeUser_participantObject:(Participants *)value;
- (void)addUser_participant:(NSSet *)values;
- (void)removeUser_participant:(NSSet *)values;

@end
