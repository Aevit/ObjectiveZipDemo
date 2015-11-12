//
//  ViewController.m
//  ObjectiveZipDemo
//
//  Created by Aevit on 15/11/12.
//  Copyright © 2015年 Aevit. All rights reserved.
//

#import "ViewController.h"
#import "FMZipManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aBtn.frame = CGRectMake(0, 0, 200, 100);
    aBtn.center = self.view.center;
    [aBtn setTitle:@"click" forState:UIControlStateNormal];
    [aBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [aBtn addTarget:self action:@selector(clickBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickBtnPressed:(UIButton*)sender {
    // 1. generate test data
    NSMutableArray *textArr = [NSMutableArray array];
    for (int i = 0; i < 5041; i++) {
        [textArr addObject:@{@"lat": @(113.2335329), @"lng": @(23.1874345)}];
    }
    
    NSString *saveInFolder = [FMZipManager createFolderWithName:@"walk" inDirectory:FMZMPathTmp];
//    NSString *saveInFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:@"walk"];
//    [[NSFileManager defaultManager] createDirectoryAtPath:saveInFolder withIntermediateDirectories:YES attributes:nil error:nil];

    
    // 2. generate plist
    NSString *fileName = [NSString stringWithFormat:@"walk-geo-%ld", time(NULL)];
    NSString *plistFilePath = [saveInFolder stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"plist"]];
    [textArr writeToFile:plistFilePath atomically:YES];
    NSLog(@"plist file path: %@", plistFilePath);
    
    NSString *zipFilePath = [FMZipManager zipOneFile:plistFilePath];
    NSLog(@"zipFilePath: %@", zipFilePath);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"please go to delete the plist now for test: %@", plistFilePath);
        NSString *unzipRs = [FMZipManager unzipFile:zipFilePath];
        NSLog(@"unzip in path: %@", unzipRs);
    });
}

@end








