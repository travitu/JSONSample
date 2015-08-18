//
//  AsynchronousViewController.m
//  JsonParseSample
//
//  Created by Toshikazu Fukuoka on 2015/08/17.
//  Copyright (c) 2015年 travitu. All rights reserved.
//

#import "AsynchronousViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AsynchronousViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic) BOOL didDetected;
@end

@implementation AsynchronousViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.didDetected = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButton:(id)sender {
    [self startCaptureSession];
}

- (IBAction)stopButton:(id)sender {
    [self stopCaptureSession];
}

- (void)startCaptureSession{
    
    [self stopCaptureSession];

    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create AVCaptureDeviceInput object
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"error:%@",error);
        return;
    }
    
    // Create capture session and add an input to the session
    self.session = [[AVCaptureSession alloc] init];
    
    if (input && [self.session canAddInput:input]) {
        [self.session addInput:input];
    } else {
        NSLog(@"addInput error");
        self.session = nil;
        return;
    }
    
    // Create capture metadata output and add to the session
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    } else {
        NSLog(@"addOutput error");
        self.session = nil;
        return;
    }
    
    // Set target metadata object types
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // Setup preview layer
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [self.session startRunning];
    
}

- (void)stopCaptureSession {
    
    self.didDetected = NO;

    if (self.session && self.session.isRunning) {
        [self.session stopRunning];
        self.session = nil;
    }
    
    if (self.preview) {
        [self.preview removeFromSuperlayer];
        self.preview = nil;
    }
}

- (void)startJsonRequest:(NSString *)urlString {

    NSURL *url = [NSURL URLWithString:urlString];
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
            [self stopCaptureSession];
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
            
            [self stopCaptureSession];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
    });

}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *data in metadataObjects) {
        if (![data isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) continue;

        if ([data.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            NSString *strValue = [(AVMetadataMachineReadableCodeObject *)data stringValue];
            
            if (!self.didDetected) {
                self.didDetected = YES;
                [self startJsonRequest:strValue];
            }
        }
    }
}

@end
