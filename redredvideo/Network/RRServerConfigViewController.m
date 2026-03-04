//
//  RRServerConfigViewController.m
//  redredvideo
//
//  服务器IP配置页面
//

#import "RRServerConfigViewController.h"
#import "RRNetworkManager.h"

@interface RRServerConfigViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *ipTextField;
@property (nonatomic, strong) UITextField *portTextField;
@property (nonatomic, strong) UIButton *confirmButton;
@end

@implementation RRServerConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"服务器配置";
    
    [self setupUI];
    [self loadSavedConfig];
}

- (void)setupUI {
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"请输入服务器地址";
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    // IP 输入框
    UILabel *ipLabel = [[UILabel alloc] init];
    ipLabel.text = @"IP 地址:";
    ipLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:ipLabel];
    
    self.ipTextField = [[UITextField alloc] init];
    self.ipTextField.placeholder = @"例如: 192.168.1.100";
    self.ipTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.ipTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.ipTextField.delegate = self;
    [self.view addSubview:self.ipTextField];
    
    // 端口输入框
    UILabel *portLabel = [[UILabel alloc] init];
    portLabel.text = @"端口:";
    portLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:portLabel];
    
    self.portTextField = [[UITextField alloc] init];
    self.portTextField.placeholder = @"默认: 3000";
    self.portTextField.text = @"3000";
    self.portTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.portTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.portTextField.delegate = self;
    [self.view addSubview:self.portTextField];
    
    // 确认按钮
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor systemRedColor];
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.confirmButton.layer.cornerRadius = 8;
    [self.confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
    
    // 提示文字
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"提示：请确保手机和服务器在同一局域网内";
    hintLabel.font = [UIFont systemFontOfSize:12];
    hintLabel.textColor = [UIColor grayColor];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.numberOfLines = 0;
    [self.view addSubview:hintLabel];
    
    // 布局
    CGFloat padding = 20;
    CGFloat width = self.view.bounds.size.width - padding * 2;
    
    titleLabel.frame = CGRectMake(padding, 100, width, 30);
    ipLabel.frame = CGRectMake(padding, 160, width, 20);
    self.ipTextField.frame = CGRectMake(padding, 190, width, 44);
    portLabel.frame = CGRectMake(padding, 254, width, 20);
    self.portTextField.frame = CGRectMake(padding, 284, width, 44);
    self.confirmButton.frame = CGRectMake(padding, 368, width, 50);
    hintLabel.frame = CGRectMake(padding, 438, width, 40);
}

- (void)loadSavedConfig {
    NSString *savedIP = [[NSUserDefaults standardUserDefaults] stringForKey:@"ServerIP"];
    NSString *savedPort = [[NSUserDefaults standardUserDefaults] stringForKey:@"ServerPort"];
    
    if (savedIP.length > 0) {
        self.ipTextField.text = savedIP;
    }
    if (savedPort.length > 0) {
        self.portTextField.text = savedPort;
    }
}

- (void)confirmButtonTapped {
    NSString *ip = [self.ipTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *port = [self.portTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (ip.length == 0) {
        [self showAlert:@"请输入 IP 地址"];
        return;
    }
    
    if (port.length == 0) {
        port = @"3000";
    }
    
    // 验证 IP 格式
    if (![self isValidIP:ip]) {
        [self showAlert:@"IP 地址格式不正确"];
        return;
    }
    
    // 保存配置
    [[NSUserDefaults standardUserDefaults] setObject:ip forKey:@"ServerIP"];
    [[NSUserDefaults standardUserDefaults] setObject:port forKey:@"ServerPort"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 更新 NetworkManager 的 baseURL
    NSString *baseURL = [NSString stringWithFormat:@"http://%@:%@", ip, port];
    [RRNetworkManager shared].baseURL = baseURL;
    
    // 回调
    if (self.onConfigured) {
        self.onConfigured();
    }
    
    // 关闭页面
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isValidIP:(NSString *)ip {
    NSArray *components = [ip componentsSeparatedByString:@"."];
    if (components.count != 4) return NO;
    
    for (NSString *component in components) {
        NSInteger value = [component integerValue];
        if (value < 0 || value > 255) return NO;
    }
    return YES;
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
