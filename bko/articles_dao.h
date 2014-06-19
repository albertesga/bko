//
//  dao.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "AFHTTPSessionManager.h"


typedef void (^FetchArticlesCompletionBlock)(NSArray *notes, NSError *error);

@interface articles_dao : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (void)getArticlesOnCompletion:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock;
- (void)getArticle:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchArticlesCompletionBlock)completionBlock;
- (void)getRelatedItems:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id related_kind:(NSNumber *)related_kind limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock;
- (void)addArticleShare:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchArticlesCompletionBlock)completionBlock;
- (void)getCard:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id y:(FetchArticlesCompletionBlock)completionBlock;
- (void)getArtistsSuggestions:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock;
- (void)getPlacesSuggestions:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock;
- (void)search:(NSString *)code_connection q:(NSString *)q limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock;
@end
