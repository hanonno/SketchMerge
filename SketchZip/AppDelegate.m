//
//  AppDelegate.m
//  SketchZip
//
//  Created by Hanno on 17/05/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "AppDelegate.h"

#import "SketchFile.h"
#import "SketchFileCollectionViewController.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow              *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
//    SketchFileCollectionController *designCollectionController = [[SketchFileCollectionController alloc] initWithDirectory:@"~/Design"];
//    [designCollectionController showWindow:self];
    
//    SketchFile *file = [[SketchFile alloc] initWithFileURL:[[NSBundle mainBundle] URLForResource:@"Symbol" withExtension:@"sketch"]];
    
    SketchFileCollectionViewController *hannoCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/Folio"];
    [hannoCollectionController showWindow:self];

//    SketchFileCollectionViewController *homeCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/United Wardrobe"];
//    [homeCollectionController showWindow:self];
//
//    SketchFileCollectionViewController *iPracticeCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/iPractice"];
//    [iPracticeCollectionController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)openDocument:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;

    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        for (NSURL *directoryURL in panel.URLs) {
            SketchFileCollectionViewController  *fileCollectionViewController = [[SketchFileCollectionViewController alloc] initWithDirectory:directoryURL.path];
            [fileCollectionViewController showWindow:self];
        }
    }];
}

@end
