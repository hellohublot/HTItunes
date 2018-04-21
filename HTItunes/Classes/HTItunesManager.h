//
//  HTItunesManager.h
//  HTItunes
//
//  Created by hublot on 2018/3/25.
//

#import <Foundation/Foundation.h>
#import "HTItunesModel.h"

typedef void(^HTItunesComplete)(NSString *applicationId, HTItunesModel *model, NSString *appstoreVersion, NSString *currentVersion, BOOL shouldUpdate, BOOL currentIsReview);

@interface HTItunesManager : NSObject

+ (NSString *)currentVersion;

+ (BOOL)isFirstInstallLaunch;

+ (void)opentApplicationId:(NSString *)applicationId;

+ (void)surePresentController:(UIViewController *)controller;

+ (void)requestLatestApplicationId:(NSString *)applicationId complete:(HTItunesComplete)complete;

+ (void)alertUpdateTitle:(NSString *)updateTitle updateDetail:(NSString *)updateDetail complete:(void(^)(BOOL sureUpdate))complete;

@end
