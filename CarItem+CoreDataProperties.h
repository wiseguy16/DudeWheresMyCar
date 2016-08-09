//
//  CarItem+CoreDataProperties.h
//  DudeWheresMyCar
//
//  Created by Gregory Weiss on 8/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CarItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface CarItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *carLocationDescription;
@property (nonatomic) double carLocationLat;
@property (nonatomic) double carLocationLong;
@property (nullable, nonatomic, retain) NSString *carLocLatString;
@property (nullable, nonatomic, retain) NSString *carLocLongString;
@property (nullable, nonatomic, retain) NSString *carDetailMisc;

@end

NS_ASSUME_NONNULL_END
