//
//  AppDelegate.m
//  SketchZip
//
//  Created by Hanno on 17/05/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "AppDelegate.h"

#import "SketchFile.h"
#import "CahierViewController.h"
#import "Cahier.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow              *window;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
//    SketchFileCollectionController *designCollectionController = [[SketchFileCollectionController alloc] initWithDirectory:@"~/Design"];
//    [designCollectionController showWindow:self];
    
//    SketchFile *file = [[SketchFile alloc] initWithFileURL:[[NSBundle mainBundle] URLForResource:@"Symbol" withExtension:@"sketch"]];
    
//    FileBrowser *hannoCollectionController = [[FileBrowser alloc] initWithDirectory:@"~/Design/United Wardrobe"];
//    CahierViewController *hannoCollectionController = [[CahierViewController alloc] initWithDirectory:@"~/Design/Hanno"];
//    [hannoCollectionController showWindow:self];

//    SketchFileCollectionViewController *homeCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/United Wardrobe"];
//    [homeCollectionController showWindow:self];
//
//    SketchFileCollectionViewController *iPracticeCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/iPractice"];
//    [iPracticeCollectionController showWindow:self];
    
    RLMResults *cahiers = [Cahier allObjects];
    for (Cahier *cahier in cahiers) {
        CahierViewController  *cahierViewController = [[CahierViewController alloc] initWithCahier:cahier];
        [cahierViewController showWindow:self];
    }
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
            Cahier *cahier = [Cahier cahierForDirectoryWithPath:directoryURL.path];
            CahierViewController  *cahierViewController = [[CahierViewController alloc] initWithCahier:cahier];
            [cahierViewController showWindow:self];
        }
    }];
}

@end
