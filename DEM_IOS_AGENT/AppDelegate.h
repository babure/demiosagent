//
//  AppDelegate.h
//  DEM_IOS_AGENT
//
//  Created by AppNeura Avekshaa on 25/08/23.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

