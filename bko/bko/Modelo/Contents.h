//
//  Contents.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content_Galleries;

@interface Contents : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSSet *content_party;
@property (nonatomic, retain) NSManagedObject *content_article;
@property (nonatomic, retain) NSSet *content_content_gallery;
@property (nonatomic, retain) NSSet *content_card;
@end

@interface Contents (CoreDataGeneratedAccessors)

- (void)addContent_partyObject:(NSManagedObject *)value;
- (void)removeContent_partyObject:(NSManagedObject *)value;
- (void)addContent_party:(NSSet *)values;
- (void)removeContent_party:(NSSet *)values;

- (void)addContent_content_galleryObject:(Content_Galleries *)value;
- (void)removeContent_content_galleryObject:(Content_Galleries *)value;
- (void)addContent_content_gallery:(NSSet *)values;
- (void)removeContent_content_gallery:(NSSet *)values;

- (void)addContent_cardObject:(NSManagedObject *)value;
- (void)removeContent_cardObject:(NSManagedObject *)value;
- (void)addContent_card:(NSSet *)values;
- (void)removeContent_card:(NSSet *)values;

@end
