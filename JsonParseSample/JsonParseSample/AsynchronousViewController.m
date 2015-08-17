//
//  AsynchronousViewController.m
//  JsonParseSample
//
//  Created by Toshikazu Fukuoka on 2015/08/17.
//  Copyright (c) 2015年 travitu. All rights reserved.
//

#import "AsynchronousViewController.h"

@interface AsynchronousViewController ()
@property (nonatomic, strong) NSData *eventData;
@end

@implementation AsynchronousViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _eventData = [NSData new];
    NSURL *url = [NSURL URLWithString:JSON_URL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSData *jsonData = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:nil
                                                       error:&error];
        
        if (error) {
            NSLog(@"error:%@",error);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (jsonData) {
                NSError *error = nil;
                NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData
                                                                                     options:NSJSONReadingAllowFragments
                                                                                       error:&error];
                if (json) {
                    NSLog(@"json:%@",json);
                }else {
                    NSLog(@"error:%@",error);
                }
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    
    });
    

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
