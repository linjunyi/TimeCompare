//
//  ViewController.m
//  TimeCompare
//
//  Created by 林君毅 on 2023/11/30.
//

#import "ViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    // 为了防止UIImage缓存影响结果，重新测试需重启App
    static NSInteger testType = 1;
    
    if (testType == 1) {
        [self useAsyncImageNodeToLoad];   // ASImageNode加载
    } else if (testType == 2) {
        [self useImageViewToLoad];        // 主线程加载
    } else if (testType == 3) {
        [self async_useImageViewToLoad];  // UIImage异步加载，回调主线程
    }
}

- (void)useImageViewToLoad {
    CFTimeInterval startTime = CACurrentMediaTime();
    CGFloat x = 15, y = 10, height = 100;
    for (NSInteger i = 0; i < 7; i++) {
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(x, y, self.view.frame.size.width-2*x, height);
        NSString *imageName = [NSString stringWithFormat:@"BigImage_%02lld", (long long)(i+1)];
        //        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        //        UIImage *image = [UIImage imageWithContentsOfFile:path];
        //        imageView.image = image;
        imageView.image = [UIImage imageNamed:imageName];
        [self.view addSubview:imageView];
        
        y += height+10;
    }
    CFTimeInterval endTime = CACurrentMediaTime();
    CFTimeInterval elapsedTime = endTime - startTime;
    NSLog(@"UIImageView loadImage代码段执行时间：%f 毫秒", elapsedTime*1000);
}

- (void)async_useImageViewToLoad {
    CFTimeInterval startTime = CACurrentMediaTime();
    CGFloat x = 15, y = 10, height = 100;
    for (NSInteger i = 0; i < 7; i++) {
        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(x, y, self.view.frame.size.width-2*x, height);
        NSString *imageName = [NSString stringWithFormat:@"BigImage_%02lld", (long long)(i+1)];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            UIImage *image = [UIImage imageNamed:imageName];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
            });
        });
        [self.view addSubview:imageView];
        
        y += height+10;
    }
    CFTimeInterval endTime = CACurrentMediaTime();
    CFTimeInterval elapsedTime = endTime - startTime;
    NSLog(@"async UIImageView loadImage代码段执行时间：%f 毫秒", elapsedTime*1000);
}

- (void)useAsyncImageNodeToLoad {
    CFTimeInterval startTime = CACurrentMediaTime();
    CGFloat x = 15, y = 10, height = 100;
    
    for (NSInteger i = 0; i < 7; i++) {
        ASImageNode *imageNode = [ASImageNode new];
        imageNode.frame = CGRectMake(x, y, self.view.frame.size.width-2*x, height);
        NSString *imageName = [NSString stringWithFormat:@"BigImage_%02lld", (long long)(i+1)];
        imageNode.image = [UIImage imageNamed:imageName];
        [self.view addSubview:imageNode.view];
        
        y += height+10;
    }
    CFTimeInterval endTime = CACurrentMediaTime();
    CFTimeInterval elapsedTime = endTime - startTime;
    NSLog(@"ASImageNode loadImage代码段执行时间：%f 毫秒", elapsedTime*1000);
}

@end
