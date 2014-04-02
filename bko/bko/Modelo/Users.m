//
//  Users.m
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "Users.h"
#import "Likes.h"
#import "Message_Threads.h"
#import "Participants.h"
#import "Plans.h"
#import "Tickets.h"
#import "Unlikes.h"


@implementation Users

@dynamic id;
@dynamic email;
@dynamic password;
@dynamic birth_date;
@dynamic name;
@dynamic surnames;
@dynamic is_publisehd;
@dynamic user_likes;
@dynamic user_unlikes;
@dynamic user_message_threads;
@dynamic user_plan;
@dynamic user_ticket;
@dynamic user_participant;

@end
