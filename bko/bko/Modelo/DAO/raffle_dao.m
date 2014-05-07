//
//  raffle_dao.m
//  bko
//
//  Created by Tito Español Gamón on 14/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "raffle_dao.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Parties.h"
#import "MTLJSONAdapter.h"

static NSString * const daoEngineBaseURL = @"http://www.bkomagazine.com/web_services/";

@implementation raffle_dao

+ (instancetype)sharedInstance {
    static raffle_dao *_sharedInstance = nil;
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
        _sharedInstance = [[raffle_dao alloc] initWithBaseURL:[NSURL URLWithString:daoEngineBaseURL] sessionConfiguration:sessionConfiguration];
    });
    
    return _sharedInstance;
}

- (void)getRaffles:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchRafflesCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"getRaffles"];
    [self GET:path parameters:@{@"connection_code":code_connection,@"limit":limit,@"page":page}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
              completionBlock([responseObject objectForKey:@"raffles"], nil);
          }
          else{
              int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
              NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
              completionBlock(nil, error);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          completionBlock(nil, error);
      }];
    
}

- (void)participateInRaffle:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchRafflesCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"participateInRaffle"];
    [self POST:path parameters:@{@"connection_code":connection_code,@"raffle_id":item_id} success:^(NSURLSessionDataTask *task, id responseObject) {
        if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[responseObject objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

- (void)deleteParticipant:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchRafflesCompletionBlock)completionBlock {
    NSString *path = [NSString stringWithFormat:@"deleteParticipant"];
    [self POST:path parameters:@{@"connection_code":connection_code,@"raffle_id":item_id} success:^(NSURLSessionDataTask *task, id responseObject) {
        if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0 ){
            NSArray *connection = [[NSArray alloc] initWithObjects:[responseObject objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[responseObject objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[responseObject objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
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
