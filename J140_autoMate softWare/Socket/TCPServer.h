//
//  TCPServer.h
//  TCP_Demo
//
//  Created by Eason on 2018/7/26.
//  Copyright © 2018年 Eason Qian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

typedef void (^serverReadDataBlock)(NSString *,NSInteger);

@interface TCPServer : NSObject

@property (nonatomic,copy) serverReadDataBlock serverReadDataBlock;
@property (nonatomic,strong) GCDAsyncSocket * serverSocket;


+(instancetype)shareInstance;
-(void)createServerSocketwitePort:(NSString *)port host:(NSString *)host;
-(void)sendBackMsg:(NSString *)str;

@end
