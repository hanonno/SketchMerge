//
//  SketchFilePlugin.m
//  vault
//
//  Created by Emiel van Liere on 02/09/15.
//  Copyright (c) 2015 ysberg. All rights reserved.
//

#import "SketchFilePlugin.h"
#import "NSImage+PNGAdditions.h"


@interface SketchFilePlugin ()

@property (nonatomic, retain) NSString *sketchToolPath;
@property (nonatomic, retain) NSTask *currentPageTask;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL taskFinished;

@end

@implementation SketchFilePlugin

- (id)init
{
    self = [super init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.sketchToolPath = @"/Applications/Sketch.app/Contents/Resources/sketchtool/bin/sketchtool";
    
    if (![fileManager fileExistsAtPath:self.sketchToolPath]) {
        self.sketchToolPath = [[NSBundle mainBundle] pathForResource:@"sketchtool/bin/sketchtool" ofType:nil];
    }
    
//    DDLogVerbose(@"SketchFilePlugin: sketchtool path %@", self.sketchToolPath);
    
    self.currentPage = NSNotFound;
    self.taskFinished = YES;
    
    return self;
}

- (NSImage *)imageForFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize
{
    @synchronized (self) {
        return [self _imageForFileWithURL:fileURL maxSize:maxSize];
    }
}

- (NSImage *)_imageForFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize
{
    NSImage *image;
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    tempDir = [tempDir URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.sketchToolPath];
    [task setArguments:@[
                         @"export",
                         @"pages",
                         fileURL.path,
                         [NSString stringWithFormat:@"--output=%@", tempDir.path]
                         ]];
    
    NSPipe *outputPipe = [[NSPipe alloc] init];
    task.standardOutput = outputPipe;
    NSFileHandle *outputFile = outputPipe.fileHandleForReading;
    
    NSPipe *errorPipe = [[NSPipe alloc] init];
    task.standardError = errorPipe;
    NSFileHandle *errorFile = errorPipe.fileHandleForReading;
    
    [task launch];
    
    NSData *errorData = [errorFile readDataToEndOfFile];

    NSString *result;
    if (errorData.length == 0) {
        result = [[NSString alloc] initWithData:[outputFile readDataToEndOfFile]
                                       encoding:NSUTF8StringEncoding];
        
        NSArray *exported = [result componentsSeparatedByString:@"\n"];
        if (exported.count > 0 && [result hasPrefix:@"Exported "]) {
            self.currentPage = 0;
            if (exported.count > 1) {
                [self findCurrentPageForFileWithURL:fileURL];
            }
        
            if (self.currentPage >= exported.count) {
//                DDLogWarn(@"Sketch reported currentPageIndex %@ but has only %@ pages in document ", @(self.currentPage), @(exported.count));
//                DDLogWarn(@"Result of sketchtool:\n%@", result);
                self.currentPage = 0;
            }
            
            NSString *exportedPage = exported[self.currentPage];
            
            if (self.currentPage != NSNotFound) {
                NSString *fileName = [exportedPage stringByReplacingOccurrencesOfString:@"Exported " withString:@""];
                NSString *outputFilePath = [tempDir.path stringByAppendingPathComponent:fileName];
                image = [[NSImage alloc] initWithContentsOfFile:outputFilePath];
            }
        }
    } else {
        result = [[NSString alloc] initWithData:errorData
                                       encoding:NSASCIIStringEncoding];
//        DDLogError(@"SketchFilePlugin error: %@", result);
    }
    
//    DDLogVerbose(@"SketchFilePlugin: %@", result);
    
    image = [image scaleToSize:maxSize];
    
    return image;
}

- (NSImage *)imageForArtboardWithID:(NSString *)artboardID inFileWithURL:(NSURL *)fileURL maxSize:(CGSize)maxSize;
{
    NSImage *image;
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    tempDir = [tempDir URLByAppendingPathComponent:[NSUUID UUID].UUIDString];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir.path withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.sketchToolPath];
    [task setArguments:@[
                         @"export",
                         @"artboards",
                         fileURL.path,
                         [NSString stringWithFormat:@"--output=%@", tempDir.path],
                         @"--use-id-for-name",
                         [NSString stringWithFormat:@"--item=%@", artboardID]
                         ]];
    
    NSLog(@"%@", tempDir.path);
    
    NSPipe *outputPipe = [[NSPipe alloc] init];
    task.standardOutput = outputPipe;
    NSFileHandle *outputFile = outputPipe.fileHandleForReading;
    
    NSPipe *errorPipe = [[NSPipe alloc] init];
    task.standardError = errorPipe;
    NSFileHandle *errorFile = errorPipe.fileHandleForReading;
    
    [task launch];
    
    NSData *errorData = [errorFile readDataToEndOfFile];
    
    //    DDLogVerbose(@"SketchFilePlugin: sketchtool for %@ in %f ms", fileURL.relativeString, [now timeIntervalSinceNow]);
    
    NSString *result;
    if (errorData.length == 0) {
        result = [[NSString alloc] initWithData:[outputFile readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
        if ([result hasPrefix:@"Exported "]) {
            NSString *outputFilePath = [[tempDir.path stringByAppendingPathComponent:artboardID] stringByAppendingPathExtension:@"png"];
            image = [[NSImage alloc] initWithContentsOfFile:outputFilePath];
        }
    } else {
        result = [[NSString alloc] initWithData:errorData encoding:NSASCIIStringEncoding];
        //        DDLogError(@"SketchFilePlugin error: %@", result);
    }
    
    //    DDLogVerbose(@"SketchFilePlugin: %@", result);
    
    image = [image scaleToSize:maxSize];
    
    return image;
}

- (void)findCurrentPageForFileWithURL:(NSURL *)fileURL
{
    
    self.currentPageTask = [[NSTask alloc] init];
    [self.currentPageTask setLaunchPath:self.sketchToolPath];
    [self.currentPageTask setArguments:@[@"dump", fileURL.path]];

    NSPipe *outputPipe = [[NSPipe alloc] init];
    self.currentPageTask.standardOutput = outputPipe;
    
    NSFileHandle *fh = [outputPipe fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:NSFileHandleDataAvailableNotification object:fh];
    
    self.taskFinished = NO;
    
    [self.currentPageTask launch];
    
    // make synchronous
    while(!self.taskFinished && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

- (void)receivedData:(NSNotification *)notification
{
    NSFileHandle *fh = (NSFileHandle *)notification.object;
    NSData *data = [fh availableData];
    
    if (data.length > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:NSFileHandleDataAvailableNotification object:fh];
        __block NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"\"currentPageIndex\" : (\\d+)"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        [regex enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            NSString *m = [str substringWithRange:[match rangeAtIndex:1]];
            self.currentPage = [m integerValue];
            
            *stop = YES;
        }];
        
    }
    
    self.taskFinished = YES;
    [self.currentPageTask terminate];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (BOOL)supportsFileExtension:(NSString *)fileExtension
{
    return [fileExtension isEqualToString:@"sketch"];
}

- (NSInteger)priority
{
    return 800;
}

- (BOOL)cacheable
{
    return YES;
}

@end
