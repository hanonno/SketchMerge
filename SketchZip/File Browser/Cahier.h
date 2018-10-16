//
//  Cahier.h
//  Cahier
//
//  Created by Hanno ten Hoor on 16/10/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Realm/Realm.h>


@class CahierViewController;


@interface Cahier : RLMObject

@property NSString                          *directory;
@property NSString                          *sizePresetName;
@property float                             zoomFactor;
@property BOOL                              windowVisible;
@property (readonly) CahierViewController   *viewController;

+ (Cahier *)cahierForDirectoryWithPath:(NSString *)directoryPath;

@end
