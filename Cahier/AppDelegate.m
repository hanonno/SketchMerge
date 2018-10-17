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

@property (weak) IBOutlet NSWindow  *window;
@property (strong) RLMResults       *cahiers;
@property (strong) NSMutableArray   *cahierControllers;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
//    SketchFileCollectionController *designCollectionController = [[SketchFileCollectionController alloc] initWithDirectory:@"~/Design"];
//    [designCollectionController showWindow:self];
    
//    SketchFile *file = [[SketchFile alloc] initWithFileURL:[[NSBundle mainBundle] URLForResource:@"Symbol" withExtension:@"sketch"]];
    
    NSLog(@"Path to realm: %@", [[[RLMRealm defaultRealm] configuration] fileURL]);
    
//    FileBrowser *hannoCollectionController = [[FileBrowser alloc] initWithDirectory:@"~/Design/United Wardrobe"];
//    CahierViewController *hannoCollectionController = [[CahierViewController alloc] initWithDirectory:@"~/Design/Hanno"];
//    [hannoCollectionController showWindow:self];

//    SketchFileCollectionViewController *homeCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/United Wardrobe"];
//    [homeCollectionController showWindow:self];
//
//    SketchFileCollectionViewController *iPracticeCollectionController = [[SketchFileCollectionViewController alloc] initWithDirectory:@"~/Design/iPractice"];
//    [iPracticeCollectionController showWindow:self];
    
    self.cahiers = [Cahier allObjects];
    self.cahierControllers = [[NSMutableArray alloc] init];

    
//    [(CahierViewController *)[[self.cahiers firstObject] viewController] showWindow:self];
    
    for (Cahier *cahier in self.cahiers) {
        if(cahier.windowVisible) {
            CahierViewController *cahierController = [[CahierViewController alloc] initWithCahier:cahier];
            [self.cahierControllers addObject:cahierController];
            [cahierController showWindow:self];
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    for (CahierViewController *cahierController in self.cahierControllers) {
        Cahier *cahier = cahierController.cahier;
        [cahier.realm beginWriteTransaction];
        cahier.windowVisible = cahierController.window.isVisible;
        [cahier.realm commitWriteTransaction];
    }
}

- (IBAction)openDocument:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;

    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        for (NSURL *directoryURL in panel.URLs) {
            for (CahierViewController *cahierController in self.cahierControllers) {
                if([cahierController.cahier.directory isEqualToString:directoryURL.path]) {
                    return [cahierController showWindow:self];
                }
            }
            
            Cahier *cahier = [Cahier cahierForDirectoryWithPath:directoryURL.path];
            CahierViewController  *cahierViewController = [[CahierViewController alloc] initWithCahier:cahier];
            [self.cahierControllers addObject:cahierViewController];
            [cahierViewController showWindow:self];
        }
    }];
}

@end
