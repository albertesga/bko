//
//  Messages.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message_Threads;

@interface Messages : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * message_thread_id;
@property (nonatomic, retain) NSNumber * is_from_user;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * is_read;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) Message_Threads *message_message_threads;

@end
