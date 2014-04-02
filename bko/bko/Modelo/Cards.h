//
//  Cards.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artists, Contents, Music_Labels;

@interface Cards : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * content_id;
@property (nonatomic, retain) NSString * list_img;
@property (nonatomic, retain) NSString * list_img_dir;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSString * img_dir;
@property (nonatomic, retain) NSString * web;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * instagram;
@property (nonatomic, retain) NSString * soundcloud;
@property (nonatomic, retain) Contents *card_content;
@property (nonatomic, retain) NSManagedObject *card_place;
@property (nonatomic, retain) Music_Labels *card_music_label;
@property (nonatomic, retain) NSManagedObject *card_generic_card;
@property (nonatomic, retain) Artists *card_artist;

@end
