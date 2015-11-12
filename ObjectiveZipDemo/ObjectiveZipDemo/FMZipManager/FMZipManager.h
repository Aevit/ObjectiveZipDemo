//
//  FMZipManager.h
//  ObjectiveZipDemo
//
//  Created by Aevit on 15/11/12.
//  Copyright © 2015年 Aevit. All rights reserved.
//

#import <Foundation/Foundation.h>

#if 0
#define ZMLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define ZMLog(x, ...)
#endif

typedef enum : NSUInteger {
    FMZMPathDocuments,
    FMZMPathLibraryCache,
    FMZMPathTmp
} FMZMPath;

@interface FMZipManager : NSObject

#pragma mark - zip one file
/**
 *  zip a file
 *  default zipped file name: the lastPathComponent of the filePath (without extension of the file)
 *
 *  @param filePath the path of the file
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFile:(NSString*)filePath;

/**
 *  zip a file
 *
 *  @param filePath the path of the file
 *  @param zipFileName the name of the final zipped file
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFile:(NSString*)filePath zipFileName:(NSString*)zipFileName;

#pragma mark - zip one folder
/**
 *  zip all of the files in the folder
 *  default zipped file name: the lastPathComponent of the folderPath
 *
 *  @param folderPath folder path
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFolder:(NSString*)folderPath;

/**
 *  zip all of the files in the folder
 *
 *  @param folderPath folder path
 *  @param zipFileName the name of the final zipped file
 *
 *  @return final zipped file path
 */
+ (NSString*)zipOneFolder:(NSString*)folderPath zipFileName:(NSString*)zipFileName;

#pragma mark - unzip file
/**
 *  unzip a zipped file
 *
 *  @param zipFilePath the path of the zip file
 *
 *  @return the path of the final unzipped file
 */
+ (NSString*)unzipFile:(NSString*)zipFilePath;

#pragma mark - helper
/**
 *  create folder
 *
 *  @param folderName the name of the folder
 *  @param zmPath     the path of the sandbox
 */
+ (NSString*)createFolderWithName:(NSString*)folderName inDirectory:(FMZMPath)zmPath;

@end
