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

#pragma mark - zip one file
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

#pragma mark - zip one folder
/**
 *  zip all of the files in the folder
 *  default zipped file name: the lastPathComponent of the folderPath
 *
 *  @param folderPath folder path
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFolder:(NSString*)folderPath {
    return [FMZipManager zipOneFolder:folderPath zipFileName:[[folderPath lastPathComponent] stringByDeletingPathExtension]];
}

/**
 *  zip all of the files in the folder
 *
 *  @param folderPath folder path
 *  @param zipFileName the name of the final zipped file
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFolder:(NSString*)folderPath zipFileName:(NSString*)zipFileName {
    return [FMZipManager zipOneFolder:folderPath zipFileName:zipFileName ozZipFile:nil];
}

/**
 *  private method
 *  if there is a sub-folder in the folder you want to zip, then traverse all the files in the sub-folder to zip
 *
 *  @param folderPath folder path
 *  @param zipFileName the name of the final zipped file
 *  @param ozZipFile   the OZZipFile object (if it is the first-layer folder, set it to nil)
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFolder:(NSString*)folderPath zipFileName:(NSString*)zipFileName ozZipFile:(OZZipFile*)ozZipFile {
    
    NSString *zipFilePath = [[FMZipManager getLastPathForPath:folderPath] stringByAppendingPathComponent:[zipFileName stringByAppendingPathExtension:@"zip"]];
    
    NSError *error = nil;
    BOOL isSubFolder = (ozZipFile ? YES : NO);
    OZZipFile *zipFile = (ozZipFile ? ozZipFile : [[OZZipFile alloc] initWithFileName:zipFilePath mode:OZZipFileModeCreate]);
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    for (id aFile in files) {
        
        NSString *path = [folderPath stringByAppendingPathComponent:aFile];
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        
        if (attributes[NSFileType] == NSFileTypeDirectory) {
            [FMZipManager zipOneFolder:path zipFileName:zipFileName ozZipFile:zipFile];
        } else if ([aFile rangeOfString:@".DS_Store"].location == NSNotFound) {
            NSDate *date = [attributes objectForKey:NSFileCreationDate];
            OZZipWriteStream *streem = [zipFile writeFileInZipWithName:aFile fileDate:date compressionLevel:OZZipCompressionLevelBest];
            NSData *data = [NSData dataWithContentsOfFile:path];
            [streem writeData:data];
            [streem finishedWriting];
        }
    }
    if (isSubFolder == NO) {
        [zipFile close];
    }
    return zipFilePath;
}

#pragma mark - unzip file
/**
 *  unzip a zipped file
 *
 *  @param zipFilePath the path of the zip file
 *
 *  @return the path of the final unzipped file
 */
#define BUFFER_SIZE (50000LL)
+ (NSString*)unzipFile:(NSString*)zipFilePath {
    
    OZZipFile *unzipFile = [[OZZipFile alloc] initWithFileName:zipFilePath mode:OZZipFileModeUnzip];
    
    NSString *documentsPath = [zipFilePath stringByReplacingOccurrencesOfString:[zipFilePath lastPathComponent] withString:@""];
    
    // Loop on file list
    NSMutableData *buffer= [[NSMutableData alloc] initWithLength:BUFFER_SIZE];
    NSArray *zipContentList= [unzipFile listFileInZipInfos];
    for (OZFileInZipInfo *info in zipContentList) {
        
        ZMLog(@"length: %llu, name: %@, date: %@, level: %ld\n\n", info.length, info.name, info.date, (long)info.level);
        
        // Check if it's a directory
        if ([info.name hasSuffix:@"/"]) {
            NSString *dirPath= [documentsPath stringByAppendingPathComponent:info.name];
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:NULL];
            continue;
        }
        
        // Create file
        NSString *filePath= [documentsPath stringByAppendingPathComponent:info.name];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:nil];
        NSFileHandle *file= [NSFileHandle fileHandleForWritingAtPath:filePath];
        
        // Seek file in zip
        [unzipFile locateFileInZip:info.name];
        OZZipReadStream *readStream= [unzipFile readCurrentFileInZip];
        
        // Reset buffer
        [buffer setLength:BUFFER_SIZE];
        
        // Loop on read stream
        int totalBytesRead = 0;
        do {
            NSUInteger bytesRead = [readStream readDataWithBuffer:buffer];
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
    
    return documentsPath;
}

#pragma mark - helper
/**
 *  create folder
 *
 *  @param folderName the name of the folder
 *  @param zmPath     the path of the sandbox
 */
+ (NSString*)createFolderWithName:(NSString*)folderName inDirectory:(FMZMPath)zmPath {
    
    NSString *finalPath = [[FMZipManager getDirectoryByZmPath:zmPath] stringByAppendingPathComponent:folderName];
    
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

+ (NSString*)getDirectoryByZmPath:(FMZMPath)zmPath {
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
