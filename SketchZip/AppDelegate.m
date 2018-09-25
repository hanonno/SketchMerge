//
//  AppDelegate.m
//  SketchZip
//
//  Created by Hanno on 17/05/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "AppDelegate.h"
#import "SSZipArchive.h"
#import "SketchDiffTool.h"
#import "SketchFilePlugin.h"
#import "CoreSync.h"
#import "CoreSyncTransaction.h"

#import "SidebarController.h"
#import "ArtboardGridViewController.h"
#import "SketchFileIndexer.h"

#import <PureLayout/PureLayout.h>

#import "SketchFileCollectionController.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow              *window;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
//    SketchFileCollectionController *designCollectionController = [[SketchFileCollectionController alloc] initWithDirectory:@"~/Design"];
//    [designCollectionController showWindow:self];

    SketchFileCollectionController *hannoCollectionController = [[SketchFileCollectionController alloc] initWithDirectory:@"~/Design/Hanno"];
    [hannoCollectionController showWindow:self];

    SketchFileCollectionController *homeCollectionController = [[SketchFileCollectionController alloc] initWithDirectory:@"~/Design/United-Wardrobe"];
    [homeCollectionController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
