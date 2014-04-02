//
//  Content_Galleries.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Content_Galleries : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * content_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * kind;
@property (nonatomic, retain) NSNumber * is_published;
@property (nonatomic, retain) NSManagedObject *content_gallery_content;
@property (nonatomic, retain) NSSet *content_gallery_content_gallery_embeds;
@property (nonatomic, retain) NSSet *content_gallery_content_gallery_image;
@end

@interface Content_Galleries (CoreDataGeneratedAccessors)

- (void)addContent_gallery_content_gallery_embedsObject:(NSManagedObject *)value;
- (void)removeContent_gallery_content_gallery_embedsObject:(NSManagedObject *)value;
- (void)addContent_gallery_content_gallery_embeds:(NSSet *)values;
- (void)removeContent_gallery_content_gallery_embeds:(NSSet *)values;

- (void)addContent_gallery_content_gallery_imageObject:(NSManagedObject *)value;
- (void)removeContent_gallery_content_gallery_imageObject:(NSManagedObject *)value;
- (void)addContent_gallery_content_gallery_image:(NSSet *)values;
- (void)removeContent_gallery_content_gallery_image:(NSSet *)values;

@end
