//
//  EncodeSignalFSK.h
//  ISEL Remoto
//
//  Created by Omr on 17/03/14.
//  Copyright (c) 2014 Omr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface EncodeSignalFSK : NSObject{
    
    
    //read only
    AudioComponentInstance toneUnit;
    double* dataQueue;
    double* PulseToSendInSignal;
    unsigned long qSteps;
    unsigned long qIndex;
    int status;
    int interval;
    
    
    
}

//Protocolo a enviar
@property (strong,nonatomic)   NSString *Protocol;

//KeyValue - Tecla a enviar
@property (strong,nonatomic)  NSString *KeyValue;



/*
 
 Summary:   Una ves configurado el protocolo y la tecla a enviar se puede enviar el codigo.
 
 
 */
 
- (void)SendDataToEmiter;

 
 /*
 
 Summary:   Obtiene el protocolo y la tecla oprimida que se require enviar.
 
 */


- (void)SetProtocol:(NSString*)protocol AndSetKeyPressed:(NSString*)keyPressed;




@end


