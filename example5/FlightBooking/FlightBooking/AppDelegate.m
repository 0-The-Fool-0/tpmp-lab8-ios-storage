//
//  AppDelegate.m
//  FlightBooking
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Record+CoreDataClass.h"

@implementation AppDelegate

@synthesize persistentContainer = _persistentContainer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self seedIfNeeded];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    ViewController *root = [[ViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:root];
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSPersistentContainer *)persistentContainer {
    if (_persistentContainer != nil) return _persistentContainer;
    _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"FlightModel"];
    [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *desc, NSError *error) {
        if (error) { abort(); }
    }];
    return _persistentContainer;
}

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if ([context hasChanges]) {
        [context save:nil];
    }
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)seedIfNeeded {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FlightSeeded"]) return;
    NSManagedObjectContext *ctx = self.persistentContainer.viewContext;
    void (^add)(NSString *, NSString *, NSString *, float) = ^(NSString *from, NSString *to, NSString *company, float price) {
        Record *r = [[Record alloc] initWithContext:ctx];
        r.cityFrom = from;
        r.cityTo = to;
        r.aviaCompany = company;
        r.price = price;
    };
    add(@"Челябинск", @"Москва", @"Аэрофлот", 1000);
    add(@"Челябинск", @"Москва", @"ЧелАвиа", 2000);
    add(@"Екатеринбург", @"Уфа", @"Аэрофлот", 500);
    [self saveContext];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FlightSeeded"];
}

@end
