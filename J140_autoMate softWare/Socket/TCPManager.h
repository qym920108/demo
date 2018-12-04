//
//  TCPManager.h
//  TCP_Demo
//
//  Created by Eason on 2018/7/26.
//  Copyright © 2018年 Eason Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

typedef void (^connectSuccessBlock)(NSString *,NSString *);
typedef void (^disconnectBlock)(NSString *);
typedef void (^readDataBlock)(NSString *);

@interface TCPManager : NSObject


@property (nonatomic,strong) GCDAsyncSocket * tcpSocket;

@property (nonatomic,copy) disconnectBlock disConnectBlock;
@property (nonatomic,copy) readDataBlock readDataBlock;
@property (nonatomic,copy) NSString * serve_ip;
@property (nonatomic,copy) NSString * serve_port;
@property (nonatomic,copy) connectSuccessBlock connectSuccessBlock;

@property (nonatomic,copy) NSString * txCMD;
@property (nonatomic,copy) NSString * rxCMD;


+(instancetype)shareInstance;
-(void)openSocketWithPort:(NSString *)port host:(NSString *)host reply:(void (^)(NSString *))reply;
-(void)closeSocket;
-(void)sendCommandData:(NSString *)str;
-(NSString *)readTestLEDStatus:(NSString *)msg slot:(int)s;





@end
