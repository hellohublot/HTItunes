//
//  HTViewController.m
//  HTItunes
//
//  Created by hellohublot on 03/25/2018.
//  Copyright (c) 2018 hellohublot. All rights reserved.
//

#import "HTViewController.h"
#import <HTItunes/HTItunes.h>

@interface HTViewController ()

@end

@implementation HTViewController

/*-------------------------------------/init /-----------------------------------*/

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initializeDataSource];
	[self initializeUserInterface];
}

- (void)initializeDataSource {
	if ([HTItunesManager isFirstInstallLaunch]) {
		NSLog(@"首次启动");
	}
	[HTItunesManager requestLatestApplicationId:@"1067751179" complete:^(NSString *applicationId, HTItunesModel *model, NSString *appstoreVersion, NSString *currentVersion, BOOL shouldUpdate, BOOL currentIsReview) {
		if (shouldUpdate) {
			[HTItunesManager alertUpdateTitle:@"更新啦" updateDetail:model.releaseNotes complete:^(BOOL sureUpdate) {
				if (sureUpdate) {
					[HTItunesManager opentApplicationId:applicationId];
				}
			}];
		}
	}];
}

- (void)initializeUserInterface {
	
}

/*-------------------------------------/ controller override /-----------------------------------*/

/*-------------------------------------/ controller leave /-----------------------------------*/


@end
