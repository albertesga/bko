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
#import "sesion.h"
#import "MTLJSONAdapter.h"

static NSString * const daoEngineBaseURL = @"http://www.bkomagazine.com/web_services/";

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

- (void)getPossibleArtistsLiked:(NSString *)code limit:(NSNumber *)limit page:(NSNumber *)page y:(FetchCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"getPossibleArtistsLiked"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(code!=nil){
        [parameters setObject:code forKey:@"connection_code"];
    }
    if(limit!=nil){
        [parameters setObject:limit forKey:@"limit"];
    }
    if(page!=nil){
        [parameters setObject:page forKey:@"page"];
    }

    [self GET:path parameters:parameters
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSDictionary *jsonDict = (NSDictionary *) responseObject;
           if([[[jsonDict objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
               completionBlock([jsonDict objectForKey:@"artists"], nil);
           }
           else{
               int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
               NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
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

          NSDictionary *jsonDict = (NSDictionary *) responseObject;
          if([[[jsonDict objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
              completionBlock([jsonDict objectForKey:@"artists"], nil);
          }
          else{
              int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
              NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
              completionBlock(nil, error);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          completionBlock(nil, error);
      }];
    
}

- (void)addUser:(NSString *)email name:(NSString *)name surname:(NSString *)surname birthdate:(NSString *)birthdate y:(FetchCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"addUser"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(email!=nil){
        //TESTING
        //email = @"fdsdfe40@gmail.com";
        
        [parameters setObject:email  forKey:@"email"];
    }
    if(name!=nil){
        [parameters setObject:name forKey:@"name"];
    }
    if(birthdate!=nil){
        [parameters setObject:birthdate forKey:@"birth_date"];
    }
    if(surname!=nil){
        [parameters setObject:surname forKey:@"surnames"];
    }
    [self GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *) responseObject;

        if([[[jsonDict objectForKey:@"response"] objectForKey:@"error"] boolValue] == FALSE){
            NSArray *connection = [[NSArray alloc] initWithObjects:[[jsonDict objectForKey:@"user"] objectForKey:@"password"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error");
        completionBlock(nil, error);
    }];
    
}

- (void)login:(NSString *)email password:(NSString *)password token:(NSString *)token y:(FetchCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"login"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(email!=nil){
        [parameters setObject:email forKey:@"email"];
    }
    if(password!=nil){
        [parameters setObject:password forKey:@"password"];
    }
    sesion *s = [sesion sharedInstance];
    NSNumber* zero = [[NSNumber alloc] initWithInt:0];
    if([s.latitude intValue] != [zero intValue]){
        [parameters setObject:s.latitude forKey:@"lat"];
    }
    if([s.longitude intValue] != [zero intValue]){
        [parameters setObject:s.longitude forKey:@"lng"];
    }
    NSLog(@"TOKEN %@",token);
    if(token!=nil){
        [parameters setObject:token forKey:@"token"];
    }
    
    NSNumber* dev = [[NSNumber alloc] initWithInt:0];
    [parameters setObject:dev forKey:@"device"];
    [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[[jsonDict objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:jsonDict, nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
    
}

- (void)recoverPassword:(NSString *)email name_surname:(NSString *)name_surname y:(FetchCompletionBlock)completionBlock{
        NSString *path = [NSString stringWithFormat:@"recoverPassword"];
        NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
        if(email!=nil){
            [parameters setObject:email forKey:@"email"];
        }
        if(name_surname!=nil){
            [parameters setValue:[name_surname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"name_surname"];
        }

        [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *jsonDict = (NSDictionary *) responseObject;
            if([[[jsonDict objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
                NSArray *connection = [[NSArray alloc] initWithObjects:jsonDict, nil];
                completionBlock(connection, nil);
            }
            else{
                int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
                NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
                completionBlock(nil, error);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completionBlock(nil, error);
        }];
}

- (void)setCoordinates:(NSString *)connection_code latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude y:(FetchCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"setCoordinates"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];

    if(latitude!=nil){
        [parameters setObject:latitude forKey:@"lat"];
    }
    if(longitude!=nil){
        [parameters setObject:longitude forKey:@"lng"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    //NSLog(@"PARAMETROS COORDENATES %@",parameters);
    [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"RESPONSE %@",responseObject);
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[[jsonDict objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[jsonDict objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
    
}

- (void)setLiked:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id like_kind:(NSNumber *)like_kind y:(FetchCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"setLiked"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"item_id"];
    }
    if(kind!=nil){
        [parameters setObject:kind forKey:@"kind"];
    }
    if(like_kind!=nil){
        [parameters setObject:like_kind forKey:@"like_kind"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    NSLog(@"LIKE PARAMS %@",parameters);
    [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"LIKE RESPONSE %@",responseObject);
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[[jsonDict objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[jsonDict objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}
- (void)setUnliked:(NSString *)connection_code kind:(NSNumber *)kind item_id:(NSNumber *)item_id like_kind:(NSNumber *)like_kind y:(FetchCompletionBlock)completionBlock{
    NSString *path = [NSString stringWithFormat:@"setUnliked"];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    if(item_id!=nil){
        [parameters setObject:item_id forKey:@"item_id"];
    }
    if(kind!=nil){
        [parameters setObject:kind forKey:@"kind"];
    }
    if(like_kind!=nil){
        [parameters setObject:like_kind forKey:@"like_kind"];
    }
    if(connection_code!=nil){
        [parameters setObject:connection_code forKey:@"connection_code"];
    }
    NSLog(@"UNLIKE PARAMS %@",parameters);
    [self POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"UNLIKE RESPONSE %@",responseObject);
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        if([[[jsonDict objectForKey:@"response"] objectForKey:@"error"] boolValue]==0){
            NSArray *connection = [[NSArray alloc] initWithObjects:[jsonDict objectForKey:@"success"], nil];
            completionBlock(connection, nil);
        }
        else{
            int id_error = (int)[[jsonDict objectForKey:@"response"] objectForKey:@"error"];
            NSError *error = [NSError errorWithDomain:@"com.bkomagazine" code:id_error userInfo:[NSDictionary dictionaryWithObject:[[jsonDict objectForKey:@"response"] objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey]];
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
