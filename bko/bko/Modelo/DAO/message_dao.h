//
//  message_dao.h
//  bko
//
//  Created by Tito Español Gamón on 14/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^FetchMessagesCompletionBlock)(NSArray *messages, NSError *error);

@interface message_dao : AFHTTPSessionManager

+ (instancetype)sharedInstance;

- (void)getMessages:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchMessagesCompletionBlock)completionBlock;
- (void)getMessage:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchMessagesCompletionBlock)completionBlock;
- (void)getUnreadMessagesCount:(NSString *)code_connection y:(FetchMessagesCompletionBlock)completionBlock;
- (void)answerMessageThread:(NSString *)connection_code item_id:(NSNumber *)item_id message:(NSString *)message y:(FetchMessagesCompletionBlock)completionBlock;
@end
