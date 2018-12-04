//
//  TCPServer.m
//  TCP_Demo
//
//  Created by Eason on 2018/7/26.
//  Copyright © 2018年 Eason Qian. All rights reserved.
//

#import "TCPServer.h"


@interface TCPServer()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket * _clientSocket;
}
@end







@implementation TCPServer

+(instancetype)shareInstance{
    static TCPServer * tcpS = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tcpS = [[self alloc]init];
    });
    return tcpS;
}

-(void)createServerSocketwitePort:(NSString *)port host:(NSString *)host{
    
    
    if (!_serverSocket) {
        _serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    
    NSError * erro = nil;
    
    [_serverSocket acceptOnPort:[port integerValue] error:&erro];
    if (erro) {
        NSLog(@"serverError:%@",erro);
    }
    
}

-(void)sendBackMsg:(NSString *)str{
    
    [_clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
}



#pragma server-Delegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    _clientSocket = newSocket;
    
    [_clientSocket readDataWithTimeout:-1 tag:0];
}


-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"serverError:%@",err);
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"sss");
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [_clientSocket readDataWithTimeout:-1 tag:0];
}


@end
