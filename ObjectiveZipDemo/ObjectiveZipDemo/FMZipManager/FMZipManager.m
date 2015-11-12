//
//  FMZipManager.m
//  ObjectiveZipDemo
//
//  Created by Aevit on 15/11/12.
//  Copyright © 2015年 Aevit. All rights reserved.
//

#import "FMZipManager.h"
#import "Objective-Zip.h"

@implementation FMZipManager

#pragma mark - zip and unzip
/**
 *  zip a file
 *  default zipped file name: the lastPathComponent of the filePath (without extension of the file)
 *
 *  @param filePath the path of the file
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFile:(NSString*)filePath {
    return [FMZipManager zipOneFile:filePath zipFileName:[[filePath lastPathComponent] stringByDeletingPathExtension]];
}

/**
 *  zip a file
 *
 *  @param filePath the path of the file
 *  @param zipFileName the name of the final zipped file
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFile:(NSString*)filePath zipFileName:(NSString*)zipFileName {
    
    // final zipped file path
    NSString *zipFilePath = [[FMZipManager getLastPathForPath:filePath] stringByAppendingPathComponent:[zipFileName stringByAppendingPathExtension:@"zip"]];
    
    NSError *error = nil;
    OZZipFile *zipFile = [[OZZipFile alloc] initWithFileName:zipFilePath mode:OZZipFileModeCreate];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    NSDate *date = [attributes objectForKey:NSFileCreationDate];
    
    // the name of the file in the zipfile
    NSString *fileName = [filePath lastPathComponent];
    OZZipWriteStream *streem = [zipFile writeFileInZipWithName:fileName fileDate:date compressionLevel:OZZipCompressionLevelBest];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [streem writeData:data];
    [streem finishedWriting];
    
    [zipFile close];
    
    return zipFilePath;
}

/**
 *  unzip a zipped file
 *
 *  @param zipFilePath the path of the zip file
 *
 *  @return the path of the final unzipped file
 */
+ (NSString*)unzipFile:(NSString*)zipFilePath {
    
    OZZipFile *unzipFile = [[OZZipFile alloc] initWithFileName:zipFilePath mode:OZZipFileModeUnzip];
    
    NSArray *zipContentList= [unzipFile listFileInZipInfos];
    OZFileInZipInfo *info = (OZFileInZipInfo*)zipContentList[0];
    ZMLog(@"length: %llu, name: %@, date: %@, level: %ld\n\n", info.length, info.name, info.date, (long)info.level);
    
    NSString *fileName = [zipFilePath lastPathComponent];
    
    NSMutableData *buffer= [[NSMutableData alloc] initWithLength:info.length];
    
    // Loop on file list
    for (OZFileInZipInfo *fileInZipInfo in zipContentList) {
        
        NSString *documentsPath = [zipFilePath stringByReplacingOccurrencesOfString:[zipFilePath lastPathComponent] withString:@""];
        
        // Check if it's a directory
        if ([fileInZipInfo.name hasSuffix:@"/"]) {
            NSString *dirPath= [documentsPath stringByAppendingPathComponent:fileInZipInfo.name];
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:NULL];
            continue;
        }
        
        // Create file
        NSString *filePath= [documentsPath stringByAppendingPathComponent:fileInZipInfo.name];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:nil];
        NSFileHandle *file= [NSFileHandle fileHandleForWritingAtPath:filePath];
        
        // Seek file in zip
        [unzipFile locateFileInZip:fileInZipInfo.name];
        OZZipReadStream *readStream= [unzipFile readCurrentFileInZip];
        
        // Reset buffer
        [buffer setLength:info.length];
        
        // Loop on read stream
        int totalBytesRead= 0;
        do {
            NSUInteger bytesRead= [readStream readDataWithBuffer:buffer];
            if (bytesRead > 0) {
                
                // Write data
                [buffer setLength:bytesRead];
                [file writeData:buffer];
                
                totalBytesRead += bytesRead;
                
            } else
                break;
            
        } while (YES);
        
        // Close file
        [file closeFile];
        [readStream finishedReading];
    }
    [unzipFile close];
    
    return fileName;
}

#pragma mark - helper
/**
 *  create folder
 *
 *  @param folderName the name of the folder
 *  @param zmPath     the path of the sandbox
 */
+ (NSString*)createFolderWithName:(NSString*)folderName inDirectory:(FMZMPath)zmPath {
    
    NSString *finalPath = [[FMZipManager getDirectoryBy:zmPath] stringByAppendingPathComponent:folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderName isDirectory:&isDir];
    if (!(isDirExist && isDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:finalPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!bCreateDir) {
            ZMLog(@"create folder failed: %@", folderName);
        }
    }
    return finalPath;
}

+ (NSString*)getLastPathForPath:(NSString*)Path {
    return [Path stringByReplacingOccurrencesOfString:[Path lastPathComponent] withString:@""];
}

+ (NSString*)getDirectoryBy:(FMZMPath)zmPath {
    switch (zmPath) {
        case FMZMPathDocuments:
        {
            return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            break;
        }
        case FMZMPathLibraryCache:
        {
            return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            break;
        }
        case FMZMPathTmp:
        {
            return NSTemporaryDirectory();
            break;
        }
        default:
            NSAssert(NO, @"get directory error");
            break;
    }
}

@end
