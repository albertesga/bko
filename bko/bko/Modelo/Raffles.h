//
//  Raffles.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Raffles : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * party_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * forWho;
@property (nonatomic, retain) NSDate * finish_date;
@property (nonatomic, retain) NSString * conditions;
@property (nonatomic, retain) NSString * reward;
@property (nonatomic, retain) NSNumber * max_winners;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) NSManagedObject *raffle_party;
@property (nonatomic, retain) NSSet *raffle_participant;
@end

@interface Raffles (CoreDataGeneratedAccessors)

- (void)addRaffle_participantObject:(NSManagedObject *)value;
- (void)removeRaffle_participantObject:(NSManagedObject *)value;
- (void)addRaffle_participant:(NSSet *)values;
- (void)removeRaffle_participant:(NSSet *)values;

@end
