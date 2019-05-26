//
//  ViewController.m
//  BindingTest
//
//  Created by Siri on 2019/5/26.
//  Copyright © 2019年 Siri. All rights reserved.
//

#import "ViewController.h"
#import "MainShowView.h"

@interface ViewController ()
@property (nonatomic ,strong) MainShowView *showView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.showView];
}

-(MainShowView *)showView{
    if (!_showView) {
        _showView = [[NSBundle mainBundle] loadNibNamed:@"MainShowView" owner:nil options:nil].lastObject;
        _showView.frame = CGRectMake(50, 100, 300, 300);
    }
    return _showView;
}



@end
