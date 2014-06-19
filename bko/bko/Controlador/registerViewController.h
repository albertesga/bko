//
//  registerViewController.h
//  bko
//
//  Created by Tito Español Gamón on 20/03/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "utils.h"

@interface registerViewController : UIViewController <FBLoginViewDelegate,UIAlertViewDelegate>

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user;

@end
