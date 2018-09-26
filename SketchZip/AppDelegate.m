//
//  AppDelegate.m
//  SketchZip
//
//  Created by Hanno on 17/05/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "AppDelegate.h"

#import "SketchFileCollectionViewController.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow              *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
//    SketchFileCollectionController *designCollectionController = [[SketchFileCollectionController alloc] initWithDirectory:@"~/Design"];
//    [designCollectionController showWindow:self];
    SketchFileCollectionViewController *hannoCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/Hanno"];
    [hannoCollectionController showWindow:self];

    SketchFileCollectionViewController *homeCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/United-Wardrobe"];
    [homeCollectionController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
