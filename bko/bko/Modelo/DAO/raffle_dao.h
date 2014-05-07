//
//  raffle_dao.h
//  bko
//
//  Created by Tito Español Gamón on 14/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^FetchRafflesCompletionBlock)(NSArray *raffles, NSError *error);

@interface raffle_dao : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (void)getRaffles:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchRafflesCompletionBlock)completionBlock;
- (void)participateInRaffle:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchRafflesCompletionBlock)completionBlock;
- (void)deleteParticipant:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchRafflesCompletionBlock)completionBlock;

@end
