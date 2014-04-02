//
//  Places.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cards, Parties;

@interface Places : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * card_id;
@property (nonatomic, retain) NSNumber * kind;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * price_text;
@property (nonatomic, retain) NSString * schedule_text;
@property (nonatomic, retain) NSString * dresscode_text;
@property (nonatomic, retain) NSString * address_text;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) NSSet *place_party;
@property (nonatomic, retain) Cards *place_card;
@end

@interface Places (CoreDataGeneratedAccessors)

- (void)addPlace_partyObject:(Parties *)value;
- (void)removePlace_partyObject:(Parties *)value;
- (void)addPlace_party:(NSSet *)values;
- (void)removePlace_party:(NSSet *)values;

@end
