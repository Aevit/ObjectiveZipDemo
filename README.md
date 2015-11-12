# ObjectiveZipDemo

Wrap apis of zip and unzip.  

Can zip a file or all files of a folder.  
Can unzip with folders if there is folder in the zip file.  

Just wrapped based on [Objective-Zip](https://github.com/gianlucabertani/Objective-Zip).


---
###Import  
Copy two folders `FMZipManager` and `Vendor/Objective-Zip` to your project.  
And then `#import "FMZipManager.h"`.

---
###Zip File


easy to use like this:  


```
// 1. zip one file  
[FMZipManager zipOneFile:yourFilePath];

// 2. or zip all files of a folder  
[FMZipManager zipOneFolder:yourFileFolder];
```

**demo**: 

```
// 1. generate test data
NSMutableArray *textArr = [NSMutableArray array];
for (int i = 0; i < 5041; i++) {
    [textArr addObject:@{@"lat": @(113.2335329), @"lng": @(23.1874345)}];
}

// 2. create folder
NSString *saveInFolder = [FMZipManager createFolderWithName:@"walk" inDirectory:FMZMPathTmp];

// 3. generate plist
NSString *fileName = [NSString stringWithFormat:@"walk-geo-%ld", time(NULL)];
NSString *plistFilePath = [saveInFolder stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"plist"]];
[textArr writeToFile:plistFilePath atomically:YES];
NSLog(@"plist file path: %@", plistFilePath);

// 4. test zip
NSString *zipFilePath = [FMZipManager zipOneFile:plistFilePath];
NSLog(@"zipFilePath: %@", zipFilePath);

// see the result here: zipFilePath
```

###Unzip File

easy to use like this:

```
[FMZipManager unzipFile:zipFilePath];
```


---
###APIs

**zip api**  

```Objective-C
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
```

**unzip api**  

```Objective-C
#pragma mark - unzip file
/**
 *  unzip a zipped file
 *
 *  @param zipFilePath the path of the zip file
 *
 *  @return the path of the final unzipped file
 */
+ (NSString*)unzipFile:(NSString*)zipFilePath;
```

**helper api**  

```Objective-C
#pragma mark - helper
/**
 *  create folder
 *
 *  @param folderName the name of the folder
 *  @param zmPath     the path of the sandbox
 */
+ (NSString*)createFolderWithName:(NSString*)folderName inDirectory:(FMZMPath)zmPath;
```


---
###Thanks
[Objective-Zip](https://github.com/gianlucabertani/Objective-Zip)  

---
###License

Portions of ObjectiveZipDemo are licensed under the original minizip license. See the minizip headers for details. All other parts of this project are licensed under the MIT license, see LICENSE.