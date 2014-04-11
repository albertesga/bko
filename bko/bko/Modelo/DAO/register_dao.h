//
//  register_dao.h
//  bko
//
//  Created by Tito Español Gamón on 07/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^FetchCompletionBlock)(NSArray *artists, NSError *error);

@interface register_dao : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (void)getPossibleArtistsLiked:(FetchCompletionBlock)completionBlock;
- (void)getAllFacebookArtists:(FetchCompletionBlock)completionBlock;
- (void)login:(NSString *)email password:(NSString *)password y:(FetchCompletionBlock)completionBlock;
- (void)addUser:(NSString *)email name:(NSString *)name surname:(NSString *)surname birthdate:(NSString *)birthdate y:(FetchCompletionBlock)completionBlock;
- (void)setCoordinates:(NSString *)connection_code latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude y:(FetchCompletionBlock)completionBlock;
- (void)setLiked:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id y:(FetchCompletionBlock)completionBlock;
- (void)setUnliked:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id y:(FetchCompletionBlock)completionBlock;

@end