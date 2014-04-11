//
//  register_dao.m
//  bko
//
//  Created by Tito Español Gamón on 07/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import "register_dao.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Artists.h"
#import "MTLJSONAdapter.h"

static NSString * const daoEngineBaseURL = @"http://192.168.1.41/";

@implementation register_dao

+ (instancetype)sharedInstance {
    static register_dao *_sharedInstance = nil;
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
        _sharedInstance = [[register_dao alloc] initWithBaseURL:[NSURL URLWithString:daoEngineBaseURL] sessionConfiguration:sessionConfiguration];
    });
    
    return _sharedInstance;
}

- (void)getPossibleArtistsLiked:(FetchCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"getPossibleArtistsLiked"];
    [self GET:path parameters:@{@"connection_code":@"XXXX",@"limit":@10,@"page":@1}
       success:^(NSURLSessionDataTask *task, id responseObject) {
        //Convertimos el objeto responseObject de un NSArray a un NSMutableArray de Artists
           NSDictionary *jsonDict = (NSDictionary *) responseObject;
           if([[jsonDict objectForKey:@"response"] objectForKey:@"error"]==0){
               NSMutableArray *articulos = [[NSMutableArray alloc] initWithCapacity:[responseObject count]];
               for (NSDictionary *JSONnoteData in responseObject) {
                   Artists *articulo = [MTLJSONAdapter modelOfClass:[Artists class] fromJSONDictionary:JSONnoteData error:nil];
                   if (articulo) [articulos addObject:articulo];
               }
               completionBlock(articulos, nil);
           }
           else{
               int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
               NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
               completionBlock(nil, error);
           }
    }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
    
}

- (void)getAllFacebookArtists:(FetchCompletionBlock)completionBlock {
    
    NSString *path = [NSString stringWithFormat:@"getAllFacebookArtists"];
    [self GET:path parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          //Convertimos el objeto responseObject de un NSArray a un NSMutableArray de Artists
          NSDictionary *jsonDict = (NSDictionary *) responseObject;
          if([[jsonDict objectForKey:@"response"] objectForKey:@"error"]==0){
              NSMutableArray *articulos = [[NSMutableArray alloc] initWithCapacity:[responseObject count]];
              for (NSDictionary *JSONnoteData in responseObject) {
                  Artists *articulo = [MTLJSONAdapter modelOfClass:[Artists class] fromJSONDictionary:JSONnoteData error:nil];
                  if (articulo) [articulos addObject:articulo];
              }
              completionBlock(articulos, nil);
          }
          else{
              int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
              NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
              completionBlock(nil, error);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          completionBlock(nil, error);
      }];
    
}

- (void)addUser:(NSString *)email name:(NSString *)name surname:(NSString *)surname birthdate:(NSString *)birthdate y:(FetchCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"addUser"];
    [self POST:path parameters:@{@"email":email,@"name":name,@"surname":name,@"birthdate":birthdate} success:^(NSURLSessionDataTask *task, id responseObject) {

        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[jsonDict objectForKey:@"response"] objectForKey:@"error"]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[[jsonDict objectForKey:@"user"] objectForKey:@"password"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
    
}

- (void)login:(NSString *)email password:(NSString *)password y:(FetchCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"login"];
    [self POST:path parameters:@{@"email":email,@"password":password,@"device":@0,@"token":@0} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[jsonDict objectForKey:@"response"] objectForKey:@"error"]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[[jsonDict objectForKey:@"connection"] objectForKey:@"code"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
    
}

- (void)setCoordinates:(NSString *)connection_code latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude y:(FetchCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"setCoordinates"];
    [self POST:path parameters:@{@"connection_code":connection_code,@"latitude":latitude,@"longitude":longitude} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[jsonDict objectForKey:@"response"] objectForKey:@"error"]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[jsonDict objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
    
}

- (void)setLiked:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id y:(FetchCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"setLiked"];
    [self POST:path parameters:@{@"connection_code":connection_code,@"kind":kind,@"item_id":item_id} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[jsonDict objectForKey:@"response"] objectForKey:@"error"]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[jsonDict objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}
- (void)setUnliked:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id y:(FetchCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"setUnliked"];
    [self POST:path parameters:@{@"connection_code":connection_code,@"kind":kind,@"item_id":item_id} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[jsonDict objectForKey:@"response"] objectForKey:@"error"]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[jsonDict objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bko" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
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
