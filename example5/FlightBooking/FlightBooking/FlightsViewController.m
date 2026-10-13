//
//  FlightsViewController.m
//  FlightBooking
//

#import "FlightsViewController.h"
#import "AppDelegate.h"
#import "Record+CoreDataClass.h"

@interface FlightsViewController ()
@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *to;
@property (nonatomic, strong) NSArray<Record *> *records;
@end

@implementation FlightsViewController

- (instancetype)initWithFrom:(NSString *)from to:(NSString *)to {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        _from = [from copy];
        _to = [to copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Рейсы";
    AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    NSFetchRequest *req = [Record fetchRequest];
    req.predicate = [NSPredicate predicateWithFormat:@"cityFrom == %@ AND cityTo == %@", self.from, self.to];
    self.records = [app.persistentContainer.viewContext executeFetchRequest:req error:nil] ?: @[];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"c"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"c"];
    Record *r = self.records[indexPath.row];
    cell.textLabel.text = r.aviaCompany;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f руб.", r.price];
    return cell;
}

@end
