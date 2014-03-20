//
//  RemoteControl.h
//  ISEL Remoto
//
//  Created by Omr on 17/03/14.
//  Copyright (c) 2014 Omr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeSignalFSK.h"

@interface RemoteControl : NSObject


@property (strong,nonatomic) EncodeSignalFSK *EncodeDataIntoSignal;



/*
    
 Summary:   Obtiene el protocolo y la tecla oprimida que se require enviar.
 
 */

- (void)SendSignalWithProtocol:(NSString*)protocol AndKeyPressed:(NSString*)KeyPressed;




@end
