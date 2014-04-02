//
//  Articles.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contents;

@interface Articles : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * content_id;
@property (nonatomic, retain) NSString * list_title;
@property (nonatomic, retain) NSString * list_img;
@property (nonatomic, retain) NSString * list_img_dir;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSString * img_dir;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * shares_count;
@property (nonatomic, retain) NSDate * published_since;
@property (nonatomic, retain) NSDate * published_until;
@property (nonatomic, retain) NSNumber * is_positive;
@property (nonatomic, retain) NSNumber * is_interview;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) Contents *article_content;

@end
