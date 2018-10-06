//
//  SketchItem.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchItem.h"


@implementation SketchItem

+ (NSString *)primaryKey {
    return @"objectId";
}

+ (NSArray *)ignoredProperties {
    return @[@"previewImage"];
}

@end
