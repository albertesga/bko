//
//  dao.m
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "articles_dao.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Articles.h"

static NSString * const daoEngineBaseURL = @"http://www.bkomagazine.com/web_services/";

@implementation articles_dao

+ (instancetype)sharedInstance {
    static articles_dao *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Network activity indicator manager setup
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        // Session configuration setup
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.HTTPAdditionalHeaders = @{
                                                       @"User-Agent"    : @"BKO iOS Client"
                                                       };
        
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024     // 10MB. memory cache
                                                          diskCapacity:50 * 1024 * 1024     // 50MB. on disk cache
                                                              diskPath:nil];
        
        sessionConfiguration.URLCache = cache;
        sessionConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        
        // Initialize the session
        _sharedInstance = [[articles_dao alloc] initWithBaseURL:[NSURL URLWithString:daoEngineBaseURL] sessionConfiguration:sessionConfiguration];
    });
    
    return _sharedInstance;
}

- (void)getArticlesOnCompletion:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(page!=nil){
        [parameters setObject:page forKey:@"page"];
    }
    NSString *path = [NSString stringWithFormat:@"getArticles"];
    NSLog(@"PARAMETRES %@",parameters);
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSLog(@"RESPONSE %@",responseObject);
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==FALSE){
              completionBlock([responseObject objectForKey:@"articles"], nil);
          }
          else{
              int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
              NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
              completionBlock(nil, error);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          completionBlock(nil, error);
      }];

}

- (void)getArticle:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchArticlesCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"getArticle"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"article_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[responseObject objectForKey:@"article"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

- (void)getRelatedItems:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id related_kind:(NSNumber *)related_kind limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock {
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"item_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    if(kind!=nil){
        [parameters setObject:kind forKey:@"kind"];
    }
    if(related_kind!=nil){
        [parameters setObject:related_kind forKey:@"related_kind"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(page!=nil){
        [parameters setObject:page forKey:@"page"];
    }
    NSString *path = [NSString stringWithFormat:@"getRelatedItems"];
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
              completionBlock([responseObject objectForKey:@"related_items"], nil);
          }
          else{
              int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
              NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
              completionBlock(nil, error);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          completionBlock(nil, error);
      }];
    
}

- (void)addArticleShare:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchArticlesCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"addArticleShare"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"item_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[responseObject objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

- (void)getCard:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id y:(FetchArticlesCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"getCard"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"item_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    if(kind!=nil){
        [parameters setObject:kind forKey:@"kind"];
    }
    [self GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[responseObject objectForKey:@"card"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
    
}

- (void)getArtistsSuggestions:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(page!=nil){
        [parameters setObject:page forKey:@"page"];
    }
    NSString *path = [NSString stringWithFormat:@"getArtistsSuggestions"];
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==FALSE){
              completionBlock([responseObject objectForKey:@"suggestions"], nil);
          }
          else{
              int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
              NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
              completionBlock(nil, error);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          completionBlock(nil, error);
      }];

    
}
- (void)getPlacesSuggestions:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(page!=nil){
        [parameters setObject:page forKey:@"page"];
    }
    NSString *path = [NSString stringWithFormat:@"getPlacesSuggestions"];
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==FALSE){
              completionBlock([responseObject objectForKey:@"suggestions"], nil);
          }
          else{
              int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
              NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
              completionBlock(nil, error);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          completionBlock(nil, error);
      }];

    
}

- (void)search:(NSString *)code_connection q:(NSString *)q limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchArticlesCompletionBlock)completionBlock{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(q!=nil){
        [parameters setObject:q forKey:@"q"];
    }
    if(page!=nil){
        [parameters setObject:page forKey:@"page"];
    }
    NSString *path = [NSString stringWithFormat:@"search"];
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==FALSE){
              completionBlock([responseObject objectForKey:@"items"], nil);
          }
          else{
              int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
              NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
              completionBlock(nil, error);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          completionBlock(nil, error);
      }];
    
    
}



- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (!self) return nil;
    
    // Configuraciones adicionales de la sesión
    
    return self;
}

@end
