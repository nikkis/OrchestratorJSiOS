//
//  OJSSecondViewController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 11.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSSecondViewController.h"

@interface OJSSecondViewController ()

@end

@implementation OJSSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


-(void) viewDidAppear:(BOOL)animated
{
    
    UIWebView *webView = (UIWebView * )[self.view viewWithTag:12];
    [webView setDelegate:self];
    
    UITextField * hostTF = (UITextField *)[self.view viewWithTag:2];
    NSString *host = hostTF.text;
    
    UITextField * portTF = (UITextField *)[self.view viewWithTag:3];
    NSString *port = portTF.text;
    
    NSString *urlAddress = [NSString stringWithFormat:@"http://%@:%@", host, port];
    //    NSString *urlAddress = @"http://orchestratorjs.org:9000/";
    
    NSLog(urlAddress);
    
    
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    
    [self.view addSubview:webView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)deviceIdentitySaveBtnTabbed
{
    UITextField *devIdTF = (UITextField*)[self.view viewWithTag:5];
    NSString *deviceIdentity = devIdTF.text;
    NSLog(deviceIdentity);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceIdentity forKey:@"deviceIdentity"];
    [defaults synchronize];
    
}



@end
