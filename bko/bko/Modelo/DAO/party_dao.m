//
//  party_dao.m
//  bko
//
//  Created by Tito Español Gamón on 14/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "party_dao.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Parties.h"
#import "MTLJSONAdapter.h"

static NSString * const daoEngineBaseURL = @"http://www.bkomagazine.com/web_services/";

@implementation party_dao

+ (instancetype)sharedInstance {
    static party_dao *_sharedInstance = nil;
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
        _sharedInstance = [[party_dao alloc] initWithBaseURL:[NSURL URLWithString:daoEngineBaseURL] sessionConfiguration:sessionConfiguration];
    });
    
    return _sharedInstance;
}

- (void)getPartiesPlaces:(NSString *)code_connection date:(NSDate *)date limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchPartiesCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"getPartiesPlaces"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    if(date!=nil){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *stringFromDate = [formatter stringFromDate:date];
        [parameters setObject:stringFromDate forKey:@"date"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(page!=nil){
        [parameters setObject:page forKey:@"page"];
    }
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
              completionBlock([responseObject objectForKey:@"places"], nil);
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

- (void)getPartiesArtists:(NSString *)code_connection date:(NSDate *)date limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchPartiesCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"getPartiesArtists"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    if(date!=nil){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSString *stringFromDate = [formatter stringFromDate:date];
        [parameters setObject:stringFromDate forKey:@"date"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(page!=nil){
        [parameters setObject:page forKey:@"page"];
    }
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
              completionBlock([responseObject objectForKey:@"artists"], nil);
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

- (void)getParty:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchPartiesCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"getParty"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"party_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    [self GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[responseObject objectForKey:@"party"], nil];
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

- (void)addPlan:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchPartiesCompletionBlock)completionBlock {
    NSString *path = [NSString stringWithFormat:@"addPlan"];
    
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"party_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    [self GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
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

- (void)removePlan:(NSString *)connection_code item_id:(NSNumber *)item_id y:(FetchPartiesCompletionBlock)completionBlock {
    NSString *path = [NSString stringWithFormat:@"removePlan"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"party_id"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    [self GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
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

- (void)getPlans:(NSString *)code_connection date:(NSDate *)date y:(FetchPartiesCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"getPlans"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code_connection!=nil){
        [parameters setObject:code_connection forKey:@"connection_code"];
    }
    if(date!=nil){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM"];
        NSString *stringFromDate = [formatter stringFromDate:date];
        [parameters setObject:stringFromDate forKey:@"year_month"];
    }
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
              completionBlock([responseObject objectForKey:@"places"], nil);
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

- (void)getTickets:(NSString *)code_connection limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchPartiesCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"getTickets"];
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
    [self GET:path parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if([[[responseObject objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
              completionBlock([responseObject objectForKey:@"tickets"], nil);
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

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (!self) return nil;
    
    // Configuraciones adicionales de la sesión
    
    return self;
}

@end
