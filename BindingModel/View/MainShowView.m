//
//  MainShowView.m
//  BindingTest
//
//  Created by Siri on 2019/5/26.
//  Copyright © 2019年 Siri. All rights reserved.
//

#import "MainShowView.h"
#import "PeopleModel.h"
#import "NSObject+BindingExpand.h"

@interface MainShowView () <UITextFieldDelegate>
@property (nonatomic ,strong)PeopleModel *model;
@end

@implementation MainShowView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.bing(@"title",^(id value){
        self.accountTF.text = value;
    }).bing(@"password",^(id value){
        self.passwordTF.text = value;
    });
    
    [self bindWithModel:self.model];
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    NSLog(@"old:%@",self.model.title);
    // 改变一
    self.model.title = @"账户改变了";
    self.model.password = @"密码改变了";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //改变二
    if (textField  == self.accountTF) {
        self.updateValue(@"title",[textField.text stringByAppendingString:string]);
    }else{
        self.updateValue(@"password",[textField.text stringByAppendingString:string]);
    }
    return YES;
}


- (PeopleModel *)model {
    if (!_model) {
        _model = [[PeopleModel alloc] init];
        _model.title = @"账户";
        _model.password = @"密码";
    }
    return _model;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
