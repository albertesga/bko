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
#import "MTLJSONAdapter.h"

static NSString * const daoEngineBaseURL = @"http://bko.com/api/";

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

- (void)fetchArticlesOnCompletion:(FetchArticlesCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"articles"];
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //Convertimos el objeti responseObject de un NSArray a un NSMutableArray de Articles
        /*NSMutableArray *articulos = [[NSMutableArray alloc] initWithCapacity:[responseObject count]];
        for (NSDictionary *JSONnoteData in responseObject) {
            Articles *articulo = [MTLJSONAdapter modelOfClass:[Articles class] fromJSONDictionary:JSONnoteData error:nil];
            if (articulo) [articulos addObject:articulo];
        }*/
        completionBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
    
}

- (void)fetchArticlesOnCompletionConImagenes:(FetchArticlesCompletionBlock)completionBlock{
    
    NSString *path = [NSString stringWithFormat:@"articles"];
    [self POST:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        UIImage *image1 = [UIImage imageNamed:@"image1"];
        NSData *image1Data = UIImageJPEGRepresentation(image1, 0.7);
        UIImage *image2 = [UIImage imageNamed:@"image2"];
        NSData *image2Data = UIImageJPEGRepresentation(image2, 0.7);
        
        [formData appendPartWithFormData:image1Data name:@"profile_avatar"];
        [formData appendPartWithFormData:image2Data name:@"profile_background"];
    }
       success:^(NSURLSessionDataTask *task, id responseObject) {
        //Convertimos el objeti responseObject de un NSArray a un NSMutableArray de Articles
        NSMutableArray *articulos = [[NSMutableArray alloc] initWithCapacity:[responseObject count]];
        for (NSDictionary *JSONnoteData in responseObject) {
            Articles *articulo = [MTLJSONAdapter modelOfClass:[Articles class] fromJSONDictionary:JSONnoteData error:nil];
            if (articulo) [articulos addObject:articulo];
        }
        
        completionBlock(articulos, nil);
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
