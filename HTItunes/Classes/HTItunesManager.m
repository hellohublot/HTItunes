//
//  HTItunesManager.m
//  HTItunes
//
//  Created by hublot on 2018/3/25.
//

#import "HTItunesManager.h"

@implementation HTItunesManager

+ (NSString *)randomValue {
	NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
	NSString *randomValue = [NSString stringWithFormat:@"%.0lf", time];
	return randomValue;
}

+ (NSString *)keyLastRequestApplicationId:(NSString *)applicationId {
	NSString *key = [NSString stringWithFormat:@"%@%@", @"kHTItunesCacheResponse", applicationId];
	return key;
}

+ (void)saveLastRequestApplicationId:(NSString *)applicationId applicationData:(NSData *)applicationData {
	NSString *key = [self keyLastRequestApplicationId:applicationId];
	NSString *value = [[NSString alloc] initWithData:applicationData encoding:NSUTF8StringEncoding];
	[[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
}

+ (NSData *)readLastRequestApplicationId:(NSString *)applicationId {
	NSString *key = [self keyLastRequestApplicationId:applicationId];
	NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
	NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
	return data;
}


+ (NSString *)currentVersion {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)isFirstInstallLaunch {
	NSString *key = @"kHTFirstLaunchKey";
	NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
	if (value.length <= 0) {
		value = [self currentVersion];
		[[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
		return true;
	} else {
		return false;
	}
}

+ (void)opentApplicationId:(NSString *)applicationId {
	NSString *applicationURLString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?t=%@", applicationId, [self randomValue]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:applicationURLString]];
}

+ (void)surePresentController:(UIViewController *)controller {
	UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (rootController.presentedViewController) {
		rootController = rootController.presentedViewController;
	}
	[rootController presentViewController:controller animated:true completion:nil];
}

+ (void)requestLatestApplicationId:(NSString *)applicationId complete:(HTItunesComplete)complete {
	NSString *applcationURLString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup/cn?id=%@&%@=%@", applicationId, @"t", [self randomValue]];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:applcationURLString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
	NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		HTItunesModel *model = [[HTItunesModel alloc] init];
		NSData *modeldata = data;
		if (modeldata.length <= 0) {
			modeldata = [self readLastRequestApplicationId:applicationId];
		} else {
			[self saveLastRequestApplicationId:applicationId applicationData:modeldata];
		}
		if (modeldata.length > 0) {
			NSDictionary *object = [NSJSONSerialization JSONObjectWithData:modeldata options:kNilOptions error:nil];
			NSDictionary <NSString *, id> *first = [[object valueForKey:@"results"] firstObject];
			if ([object isKindOfClass:[NSDictionary<NSString *, id> class]] && object.count > 0) {
				[model setValuesForKeysWithDictionary:first];
			}
		}
		NSString *appstoreVersion = model.version;
		NSString *currentVersion = [self currentVersion];
		NSComparisonResult compareResult = [currentVersion compare:appstoreVersion options:NSNumericSearch];
		BOOL shouldUpdate = compareResult == NSOrderedAscending;
		BOOL currentIsReview = compareResult == NSOrderedDescending;
		if (complete) {
			dispatch_async(dispatch_get_main_queue(), ^{
				complete(applicationId, model, appstoreVersion, currentVersion, shouldUpdate, currentIsReview);
			});
		}
	}];
	[task resume];
}

+ (void)alertUpdateTitle:(NSString *)updateTitle updateDetail:(NSString *)updateDetail complete:(void(^)(BOOL sureUpdate))complete {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:updateTitle message:updateDetail preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[alertController dismissViewControllerAnimated:true completion:nil];
		if (complete) {
			complete(true);
		}
	}];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		[alertController dismissViewControllerAnimated:true completion:nil];
		if (complete) {
			complete(false);
		}
	}];
	[alertController addAction:sureAction];
	[alertController addAction:cancelAction];
	[self surePresentController:alertController];
}

@end
