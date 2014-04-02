//
//  Relateds.h
//  bko
//
//  Created by Tito Español Gamón on 02/04/14.
//  Copyright (c) 2014 bko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Relateds : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * model_1;
@property (nonatomic, retain) NSString * model_2;
@property (nonatomic, retain) NSNumber * foreign_key_1;
@property (nonatomic, retain) NSNumber * foreign_key_2;

@end
