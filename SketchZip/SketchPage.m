//
//  SketchPage.m
//  SketchZip
//
//  Created by Hanno ten Hoor on 02/08/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "SketchPage.h"

@implementation SketchArtboard

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];

    _JSON = JSON;
    _objectId = JSON[@"do_objectID"];
    _image = nil;
    
    return self;
}

- (NSString *)name {
    return _JSON[@"name"];
}

@end


@implementation SketchPage

- (id)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    
    _JSON = JSON;
    _artboards = nil;
    _changedArtboards = nil;
    
    return self;
}

- (void)insertArtboard:(SketchArtboard *)artboard {
    
}

- (void)updateArtboard:(SketchArtboard *)artboard {
    
}

- (void)deleteArtboard:(SketchArtboard *)artboard {
    
}

@end
