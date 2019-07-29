//
//  ViewController.m
//  GCD打印
//
//  Created by 赵鹏 on 2019/7/29.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self test];
    
//    [self test1];
    
//    [self test2];
    
//    [self test3];
}

//在主线程中执行下面的代码
- (void)test
{
    NSLog(@"1");
    
    /**
     从源码可知，这句代码的意思是添加了一个马上触发的定时器放到了RunLoop里面；
     这句代码要触发的前提是要有一个RunLoop，主线程的RunLoop是自动开启的，所以这句代码有效，所以打印的结果是"1 3 2"。
     */
    [self performSelector:@selector(test4) withObject:nil afterDelay:0.0];
    
    NSLog(@"3");
}

- (void)test1
{
    //获取全局的并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //异步函数
    dispatch_async(queue, ^{
        NSLog(@"1");
        
        /**
         在新创建的子线程中执行如下的任务；
         这句代码的意思是添加了一个马上触发的定时器放到了RunLoop里面；
         这句代码要触发的前提是要有一个RunLoop，但是这是在子线程中，子线程中没有自动生成的RunLoop，所以这句代码并不执行，所以打印的结果是"1 3"。
         */
        [self performSelector:@selector(test4) withObject:nil afterDelay:0.0];
        
        NSLog(@"3");
        
        /**
         若想要在子线程中执行上一句代码的话，就要创建一个RunLoop，代码如下所示；
         加上下面的代码以后，打印的结果就为"1 3 2"。
         */
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    });
}

- (void)test2
{
    //获取全局的并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //异步函数
    dispatch_async(queue, ^{
        NSLog(@"1");
        
        //打印结果是"1 2 3"。
        [self performSelector:@selector(test4) withObject:nil];
        
        NSLog(@"3");
    });
}

/**
 程序在执行本方法的时候会先打印"1"，然后程序会崩溃掉；
 程序首先会创建一个子线程，准备在该子线程中执行"NSLog(@"1")"任务，当调用start方法的时候该子线程会开始执行block代码块中的任务，后面的"performSelector:"方法也是指定在该子线程中执行test任务，所以子线程会首先执行block代码块内的任务，所以打印的结果是"1"。当执行完了这个打印任务以后，这个任务就算做完了，所以这个子线程就会退出，所以就不能再继续执行后面的test任务了，以至于会出现程序崩溃的现象。
 */
- (void)test3
{
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1");
        
        /**
         想要执行test任务的话就要撰写如下的代码：
         在子线程中开启一个RunLoop，当执行完"NSLog(@"1")"任务以后，RunLoop会让这个子线程进入到休眠状态，等待系统给这个子线程发消息，当这个子线程接收到test消息的时候就被唤醒，然后继续执行这个test任务，所以打印的结果是"1 2"。
         */
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }];
    
    [thread start];
    
    [self performSelector:@selector(test4) onThread:thread withObject:nil waitUntilDone:YES];
}

- (void)test4
{
    NSLog(@"2");
}

@end
