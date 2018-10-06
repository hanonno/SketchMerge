//
//  SketchItem.h
//  SketchZip
//
//  Created by Hanno ten Hoor on 06/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>


@interface SketchItem : RLMObject

@property (strong) NSString     *objectId;
@property (strong) NSString     *objectClass;

@property (strong) NSString     *fileId;
@property (strong) NSString     *filePath;

@property (strong) NSString     *pageId;
@property (strong) NSString     *pageName;

@property (strong) NSString     *name;

@property (assign) float        x;
@property (assign) float        y;
@property (assign) float        width;
@property (assign) float        height;

// Artboard only
@property (strong) NSString     *presetName;
@property (assign) float        presetWidth;
@property (assign) float        presetHeight;

@property (strong) NSString     *textContent;           // Used for full text search

@property (strong) NSImage      *previewImage;
@property (strong) NSString     *previewImagePath;

@end
