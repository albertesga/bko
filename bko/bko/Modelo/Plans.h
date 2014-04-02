//
//  Plans.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Plans : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * party_id;
@property (nonatomic, retain) NSManagedObject *plan_user;
@property (nonatomic, retain) NSManagedObject *plan_party;

@end
