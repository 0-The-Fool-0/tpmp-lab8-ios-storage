//
//  ViewController.m
//  FlightBooking
//

#import "ViewController.h"
#import "FlightsViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()
@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) UITextField *cityFrom;
@property (nonatomic, strong) UITextField *cityTo;
@property (nonatomic) int isCity;
@property (nonatomic, strong) MKPointAnnotation *annotationFrom;
@property (nonatomic, strong) MKPointAnnotation *annotationTo;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Бронирование";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.map = [[MKMapView alloc] initWithFrame:CGRectZero];
    self.map.translatesAutoresizingMaskIntoConstraints = NO;
    self.map.delegate = self;
    [self.view addSubview:self.map];
    self.cityFrom = [self fieldWithPlaceholder:@"From"];
    self.cityTo = [self fieldWithPlaceholder:@"To"];
    self.cityFrom.delegate = self;
    self.cityTo.delegate = self;
    UIButton *find = [UIButton buttonWithType:UIButtonTypeSystem];
    [find setTitle:@"Find" forState:UIControlStateNormal];
    [find addTarget:self action:@selector(showFlights) forControlEvents:UIControlEventTouchUpInside];
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.cityFrom, self.cityTo, find]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [self.map.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.map.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.map.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.map.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.55],
        [stack.topAnchor constraintEqualToAnchor:self.map.bottomAnchor constant:12],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16]
    ]];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(55.15, 61.4);
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(center, 400000, 400000) animated:NO];
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.map addGestureRecognizer:lp];
}

- (UITextField *)fieldWithPlaceholder:(NSString *)ph {
    UITextField *f = [[UITextField alloc] init];
    f.placeholder = ph;
    f.borderStyle = UITextBorderStyleRoundedRect;
    return f;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) return;
    CGPoint point = [sender locationInView:self.map];
    CLLocationCoordinate2D coord = [self.map convertPoint:point toCoordinateFromView:self.map];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    __weak typeof(self) weakSelf = self;
    [geo reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> *marks, NSError *error) {
        NSString *city = marks.firstObject.locality ?: @"?";
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setAnnotation:weakSelf.isCity title:city coordinate:coord];
        });
    }];
}

- (void)setAnnotation:(int)type title:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate {
    if (type == 0) {
        if (self.annotationFrom) [self.map removeAnnotation:self.annotationFrom];
        self.annotationFrom = [[MKPointAnnotation alloc] init];
        self.annotationFrom.title = title;
        self.annotationFrom.coordinate = coordinate;
        [self.map addAnnotation:self.annotationFrom];
        self.cityFrom.text = title;
    } else {
        if (self.annotationTo) [self.map removeAnnotation:self.annotationTo];
        self.annotationTo = [[MKPointAnnotation alloc] init];
        self.annotationTo.title = title;
        self.annotationTo.coordinate = coordinate;
        [self.map addAnnotation:self.annotationTo];
        self.cityTo.text = title;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.cityFrom) self.isCity = 0;
    else if (textField == self.cityTo) self.isCity = 1;
    [textField resignFirstResponder];
}

- (void)showFlights {
    FlightsViewController *vc = [[FlightsViewController alloc] initWithFrom:self.cityFrom.text to:self.cityTo.text];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
