//
//  TCPManager.m
//  TCP_Demo
//
//  Created by Eason on 2018/7/26.
//  Copyright © 2018年 Eason Qian. All rights reserved.
//

#import "TCPManager.h"
#import "GCDAsyncSocket.h"

#define TCP_PORT @"0821"
#define TCP_IP @"172.18.12.112"


@interface TCPManager()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket * _tcpSocket;
    NSString * _slot;

    
}


@end

@implementation TCPManager

+(instancetype)shareInstance{
    static TCPManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc]init];
    });
    
    return _manager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}


-(void)openSocketWithPort:(NSString *)port host:(NSString *)host reply:(void (^)(NSString *))reply{
    
    if (!_tcpSocket) {
        _tcpSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

    }
        
    NSError * error = nil;
    
    [_tcpSocket connectToHost:host onPort:[port integerValue] error:&error];
    
    if (error) {
        //NSLog(@"连接失败%@",error);
        NSString * errorString = [NSString stringWithFormat:@"%@",error];
        reply(errorString);
    }
    
    
    
}

-(void)sendCommandData:(NSString *)str{
    
    //NSLog(@"send:%@",str);
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.tcpSocket writeData:data withTimeout:-1 tag:1];
    
}

-(NSString *)readTestLEDStatus:(NSString *)msg slot:(int)s{
    [NSThread sleepForTimeInterval:0.1];
    NSString * str;
    if ([msg containsString:@"SKIP"]) {
        str = [NSString stringWithFormat:@"%d:00000000000000000:SKIP",s];
    }
    else{
        [self sendCommandData:[NSString stringWithFormat:@"ReadTestLed:0%d;",s]];
        
        if ([_slot containsString:[NSString stringWithFormat:@"ReadTestLed:0%d:DATA:02",s]]) {
            str = [NSString stringWithFormat:@"%d:%@:PASS",s,msg];
        }
        else if ([_slot containsString:[NSString stringWithFormat:@"ReadTestLed:0%d:DATA:04",s]]){
            str = [NSString stringWithFormat:@"%d:%@:FAIL",s,msg];
        }
    }
    
    
    
    return str;
}







-(void)closeSocket{
    if (self.tcpSocket) {
        [self.tcpSocket disconnect];
        self.tcpSocket.delegate = nil;
        self.tcpSocket = nil;

    }
}











#pragma TCP-Delegate
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"connect OK");
    if (_connectSuccessBlock) {
        _connectSuccessBlock(host,[NSString stringWithFormat:@"%hu",port]);
    }
    
    
    
    [self.tcpSocket readDataWithTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (_disConnectBlock) {
        _disConnectBlock([NSString stringWithFormat:@"%@",err]);
    }
    
    NSLog(@"connect Stop");
    
    [self closeSocket];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString * str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    _slot = [NSString stringWithFormat:@"str"];
    NSLog(@"[RX]=>%@",_slot);
    if (_readDataBlock) {
        _readDataBlock(str);
    }
    
    [self.tcpSocket readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //NSLog(@"发送成功");
}









@end
