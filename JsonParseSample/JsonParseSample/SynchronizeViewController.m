//
//  SynchronizeViewController.m
//  JsonParseSample
//
//  Created by Toshikazu Fukuoka on 2015/08/17.
//  Copyright (c) 2015年 travitu. All rights reserved.
//

#import "SynchronizeViewController.h"

@interface SynchronizeViewController ()

@end

@implementation SynchronizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:JSON_URL];
    NSLog(@"url:%@",url);
    
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfURL:url options:kNilOptions error:&error];
    if (jsonData) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (jsonDict) {
            NSLog(@"apiley:%@",  [jsonDict objectForKey:@"apiley"] );
            NSLog(@"spotid:%@",  [jsonDict objectForKey:@"spotid"] );
        }
    }else {
        NSLog(@"error:%@",error);
    }
    

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        NSError *error = nil;
//        
//        NSMutableDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error: &error];
//        
//        if (error) {
//            // you have to show the alert on the main thread
//            dispatch_async(dispatch_get_main_queue, ^(void) {
//                [[[UIAlertView alloc] initWithTitle:@"Error" message:error.userInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            });
//        }
//    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
