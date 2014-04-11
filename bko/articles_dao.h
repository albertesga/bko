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

- (void)fetchArticlesOnCompletion:(FetchArticlesCompletionBlock)completionBlock;

@end
