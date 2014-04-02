//
//  Message_Threads.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message_Threads : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSManagedObject *message_threads_user;
@property (nonatomic, retain) NSSet *message_threads_message;
@end

@interface Message_Threads (CoreDataGeneratedAccessors)

- (void)addMessage_threads_messageObject:(NSManagedObject *)value;
- (void)removeMessage_threads_messageObject:(NSManagedObject *)value;
- (void)addMessage_threads_message:(NSSet *)values;
- (void)removeMessage_threads_message:(NSSet *)values;

@end
