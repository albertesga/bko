//
//  message_dao.m
//  bko
//
//  Created by Tito Español Gamón on 14/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "message_dao.h"
#import "AFNetworkActivityIndicatorManager.h"

static NSString * const daoEngineBaseURL = @"http://www.bkomagazine.com/web_services/";

@implementation message_dao

+ (instancetype)sharedInstance {
    static message_dao *_sharedInstance = nil;
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
        _sharedInstance = [[message_dao alloc] initWithBaseURL:[NSURL URLWithString:daoEngineBaseURL] sessionConfiguration:sessionConfiguration];
    });
    
    return _sharedInstance;
}

- (void)getMessages:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchMessagesCompletionBlock)completionBlock{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(page!=nil)
    {
        [parameters setObject:page forKey:@"page"];
    }
    NSString *path = [NSString stringWithFormat:@"getMessageThreads"];
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==FALSE){
              completionBlock([responseObject objectForKey:@"message_threads"], nil);
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

- (void)getMessage:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchMessagesCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"getMessageThread"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"message_thread_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==FALSE){
            NSArray *connection = [[NSArray alloc] initWithObjects:responseObject, nil];
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

- (void)getUnreadMessagesCount:(NSString *)code_connection y:(FetchMessagesCompletionBlock)completionBlock{
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    NSString *path = [NSString stringWithFormat:@"getUnreadMessagesCount"];
    
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==FALSE){
              NSArray *connection = [[NSArray alloc] initWithObjects:responseObject, nil];
              completionBlock(connection, nil);
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

- (void)answerMessageThread:(NSString *)connection_code item_id:(NSNumber *)item_id message:(NSString *)message y:(FetchMessagesCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"answerMessageThread"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"message_thread_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    if(message!=nil){
        [parameters setObject:message forKey:@"message"];
    }
    
    [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==FALSE){
            NSArray *connection = [[NSArray alloc] initWithObjects:[responseObject valueForKey:@"success"], nil];
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



- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (!self) return nil;
    
    // Configuraciones adicionales de la sesión
    
    return self;
}

@end
