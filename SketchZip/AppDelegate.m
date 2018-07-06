//
//  AppDelegate.m
//  SketchZip
//
//  Created by Hanno on 17/05/2018.
//  Copyright © 2018 Motion Pixel. All rights reserved.
//

#import "AppDelegate.h"
#import "SSZipArchive.h"
#import "SketchFile.h"
#import "CoreSync.h"
#import "CoreSyncTransaction.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSURL *rootFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-Root" ofType:@"sketch"]];
    NSURL *changedFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-B" ofType:@"sketch"]];

    SketchFile *sketchFile = [[SketchFile alloc] init];

    NSDictionary *pages = [sketchFile _pagesFromFileAtURL:rootFileURL];
    NSArray *transactions = [sketchFile diffFromFile:rootFileURL to:changedFileURL];

    for (CoreSyncTransaction *transaction in transactions) {
//        NSLog(@"%@", transaction.keyPath);
        
        NSLog(@"page: %@ > layer index: %li", transaction.pageID, (long)transaction.artboardIndex);
        
        
        NSDictionary *page = pages[transaction.pageID];
        NSArray *layers = page[@"layers"];
        
        NSDictionary *artboard = [layers objectAtIndex:transaction.artboardIndex];
        
        NSLog(@"%@", artboard);
    }

//    sketchtool export artboards path/to/document.sketch --formats=jpg,png,svg
//    sketchtool export artboards path/to/document.sketch --scales=1,2


    
    
//    NSURL *rootFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-Root" ofType:@"sketch"]];
//    NSURL *myFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-A" ofType:@"sketch"]];
//    NSURL *theirFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Artboards-B" ofType:@"sketch"]];
//
//    SketchFile *sketchFile = [[SketchFile alloc] init];
//
//    NSArray *myDiff = [sketchFile diffFromFile:rootFileURL to:myFileURL];
//    NSArray *theirDiff = [sketchFile diffFromFile:rootFileURL to:theirFileURL];
//
//    NSDictionary *myTransactions = @{ @"transactions": myDiff };
//    NSDictionary *theirTransactios = @{ @"transactions": theirDiff };
//
//    NSArray *diff = [CoreSync diffAsTransactions:myTransactions :theirTransactios];
    
//    NSDictionary *originalArtboards = [sketchFile artboardsForFileWithURL:originalFileURL];
//    NSDictionary *newArtboards = [sketchFile artboardsForFileWithURL:newFileURL];
//
//    if([originalArtboards isEqualToDictionary:newArtboards]) {
//        NSLog(@"Equal!");
//    }
//
//    NSArray* JSONChanges = [CoreSync diffAsTransactions:originalArtboards :newArtboards];
//    NSLog(@"%@", JSONChanges);

    
//    NSArray *
    
}

- (void)test {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TestFile1" ofType:@"sketch"];
    
    NSString *destination = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TestFile1"];
    NSString *rezipped = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TestFile2"];
    
    [SSZipArchive unzipFileAtPath:path toDestination:destination];
    [SSZipArchive createZipFileAtPath:rezipped withContentsOfDirectory:destination];
    
    NSLog(@"Destination: %@", destination);
    NSLog(@"Rezipped: %@", rezipped);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
