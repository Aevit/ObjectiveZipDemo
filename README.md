# ObjectiveZipDemo
ObjectiveZipDemo

Just wrapped based on [Objective-Zip](https://github.com/gianlucabertani/Objective-Zip).


###Import  
Copy two folders `FMZipManager` and `Vendor/Objective-Zip` to your project.  
And then `#import "FMZipManager.h"`.

###Zip File

easy to use like this:  

```
[FMZipManager zipOneFile:yourFilePath];
```

demo: 

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

// 4. zip
NSString *zipFilePath = [FMZipManager zipOneFile:plistFilePath];
NSLog(@"zipFilePath: %@", zipFilePath);
```

###Unzip File

easy to use like this:

```
[FMZipManager unzipFile:zipFilePath];
```