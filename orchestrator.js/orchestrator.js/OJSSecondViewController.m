//
//  OJSSecondViewController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 11.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSSecondViewController.h"

#import "OJSSettingsManager.h"

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
    [self.view addSubview:webView];
    
    OJSSettingsManager *settingsManager = [OJSSettingsManager settingsManager];
    NSString *urlAddress = [NSString stringWithFormat:@"http://%@:%@", [settingsManager getHostName], [settingsManager getHostPort]];
    
    NSLog(urlAddress);
    
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:requestObj];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
