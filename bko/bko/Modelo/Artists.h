//
//  Artists.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Artists : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * card_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) NSManagedObject *artist_card;

@end
