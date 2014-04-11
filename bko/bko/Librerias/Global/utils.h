//
//  utils.h
//  bko
//
//  Created by Tito Español Gamón on 10/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface utils : NSObject
{
    NSString *userAllowDocName;
    NSString *userDataDocName;
}

+ (Boolean) userAllowedToUseApp;

+ (void) allowUserToUseApp:(NSString *)userName password:(NSString *)password;

+ (NSMutableDictionary *) retriveUsernamePassword;

+ (NSString *) prettyDate:(NSDate *) date;
@end
