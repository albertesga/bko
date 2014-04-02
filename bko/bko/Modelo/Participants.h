//
//  Participants.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Raffles;

@interface Participants : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * raffle_id;
@property (nonatomic, retain) NSNumber * is_winner;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSManagedObject *participant_user;
@property (nonatomic, retain) Raffles *participant_raffle;

@end
