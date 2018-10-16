//
//  Cahier.h
//  Cahier
//
//  Created by Hanno ten Hoor on 16/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Realm/Realm.h>


@interface Cahier : RLMObject

@property (strong) NSString     *directory;
@property (strong) NSString     *sizePresetName;
@property (assign) float        zoomFactor;

+ (Cahier *)cahierForDirectoryWithPath:(NSString *)directoryPath;

@end
