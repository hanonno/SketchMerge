//
//  SketchLayer.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchLayer.h"



@implementation SketchArtboard

- (id)init {
    NSData *artboardData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"artboard" ofType:@"json"]];
    NSMutableDictionary *artboardJSON = [NSJSONSerialization JSONObjectWithData:artboardData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
    
    self = [super initWithJSON:artboardJSON fromPage:nil];
    
    self.JSON[@"do_objectID"] = [[NSUUID UUID] UUIDString];
    
    return self;
}

@end


@implementation SketchRect

- (id)init {
    NSData *rectangleData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rectangle" ofType:@"json"]];
    NSMutableDictionary *rectangleJSON = [NSJSONSerialization JSONObjectWithData:rectangleData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
    
    self = [super initWithJSON:rectangleJSON fromPage:nil];
    
    
    //    NSMutableDictionary *frame = [self.JSON objectForKey:@"frame"];
    //    NSInteger width = [(NSNumber *)[frame objectForKey:@"width"] integerValue];
    
    self.JSON[@"do_objectID"] = [[NSUUID UUID] UUIDString];
    
    return self;
}

- (NSMutableDictionary *)frame {
    return self.JSON[@"frame"];
}

//- (NSInteger)x {
//    return [[self.JSON[@"frame"] objectForKey:@"x"] integerValue];
//}
//
//- (void)setX:(NSInteger)x {
//    [[self frame] setObject:[NSNumber numberWithInteger:x] forKey:@"x"];
//}
//
//- (NSInteger)y {
//    return [[self.JSON[@"frame"] objectForKey:@"y"] integerValue];
//}
//
//- (void)setY:(NSInteger)y {
//    [[self frame] setObject:[NSNumber numberWithInteger:y] forKey:@"y"];
//}
//
//- (NSInteger)width {
//    return [[self.JSON[@"frame"] objectForKey:@"width"] integerValue];
//}
//
//- (void)setWidth:(NSInteger)width {
//    [[self frame] setObject:[NSNumber numberWithInteger:width] forKey:@"width"];
//}
//
//- (NSInteger)height {
//    return [[self.JSON[@"frame"] objectForKey:@"height"] integerValue];
//}
//
//- (void)setHeight:(NSInteger)height {
//    [[self frame] setObject:[NSNumber numberWithInteger:height] forKey:@"height"];
//}

@end


@implementation SketchText

- (id)init {
    NSData *textData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"text" ofType:@"json"]];
    NSMutableDictionary *textJSON = [NSJSONSerialization JSONObjectWithData:textData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
    
    self = [super initWithJSON:textJSON fromPage:nil];
    
    self.JSON[@"do_objectID"] = [[NSUUID UUID] UUIDString];
    
    return self;
}

@end
