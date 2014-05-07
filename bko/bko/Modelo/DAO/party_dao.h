//
//  party_dao.h
//  bko
//
//  Created by Tito Español Gamón on 14/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "AFHTTPSessionManager.h"


typedef void (^FetchPartiesCompletionBlock)(NSArray *parties, NSError *error);

@interface party_dao : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (void)getPartiesPlaces:(NSString *)code_connection date:(NSDate *)date limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchPartiesCompletionBlock)completionBlock;
- (void)getPartiesArtists:(NSString *)code_connection date:(NSDate *)date limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchPartiesCompletionBlock)completionBlock;
- (void)getParty:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchPartiesCompletionBlock)completionBlock;
- (void)addPlan:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchPartiesCompletionBlock)completionBlock;
- (void)removePlan:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchPartiesCompletionBlock)completionBlock;
- (void)getPlans:(NSString *)code_connection date:(NSDate *)date y:(FetchPartiesCompletionBlock)completionBlock;

@end
