//
//  Content_Gallery_Embeds.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content_Galleries;

@interface Content_Gallery_Embeds : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * content_gallery_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) Content_Galleries *content_gallery_embeds_content_gallery;

@end
