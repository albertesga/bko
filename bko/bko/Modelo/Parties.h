//
//  Parties.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contents, Plans, Raffles, Tickets;

@interface Parties : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * content_id;
@property (nonatomic, retain) NSNumber * place_id;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSString * list_name;
@property (nonatomic, retain) NSString * list_description;
@property (nonatomic, retain) NSString * list_img;
@property (nonatomic, retain) NSString * list_img_dir;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSString * img_dir;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * price_text;
@property (nonatomic, retain) NSString * schedule_text;
@property (nonatomic, retain) NSString * dresscode_text;
@property (nonatomic, retain) NSString * address_text;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * tickets_link;
@property (nonatomic, retain) NSString * list_link;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) NSSet *party_plan;
@property (nonatomic, retain) NSSet *party_ticket;
@property (nonatomic, retain) NSSet *party_raffle;
@property (nonatomic, retain) Contents *party_content;
@property (nonatomic, retain) NSManagedObject *party_place;
@end

@interface Parties (CoreDataGeneratedAccessors)

- (void)addParty_planObject:(Plans *)value;
- (void)removeParty_planObject:(Plans *)value;
- (void)addParty_plan:(NSSet *)values;
- (void)removeParty_plan:(NSSet *)values;

- (void)addParty_ticketObject:(Tickets *)value;
- (void)removeParty_ticketObject:(Tickets *)value;
- (void)addParty_ticket:(NSSet *)values;
- (void)removeParty_ticket:(NSSet *)values;

- (void)addParty_raffleObject:(Raffles *)value;
- (void)removeParty_raffleObject:(Raffles *)value;
- (void)addParty_raffle:(NSSet *)values;
- (void)removeParty_raffle:(NSSet *)values;

@end
