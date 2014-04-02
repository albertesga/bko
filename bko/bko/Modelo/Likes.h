//
//  Likes.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Likes : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSNumber * foreign_key;
@property (nonatomic, retain) NSManagedObject *likes_user;

@end
