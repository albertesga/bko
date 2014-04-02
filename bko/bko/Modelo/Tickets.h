//
//  Tickets.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tickets : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * party_id;
@property (nonatomic, retain) NSString * qr;
@property (nonatomic, retain) NSString * qr_dir;
@property (nonatomic, retain) NSNumber * is_used;
@property (nonatomic, retain) NSManagedObject *ticket_user;
@property (nonatomic, retain) NSManagedObject *ticket_party;

@end
