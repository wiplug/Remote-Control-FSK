//
//  RemoteControl.m
//  ISEL Remoto
//
//  Created by Omr on 17/03/14.
//  Copyright (c) 2014 Omr. All rights reserved.
//

#import "RemoteControl.h"

@implementation RemoteControl


- (id)init
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        // initialization happens here ...
        NSLog(@"se inicio Remote Control");
        
        _EncodeDataIntoSignal = [ [EncodeSignalFSK alloc] init ];
    
    }
    return self;
}


/*
 
 
 @summary:  Obtiene el protocolo y la tecla oprimida del protocolo seleccionado.
 @param:    protocol    Codigo del protocolo siguiendo los estanares.001~N
 @param:    KeyPressed  Codigo de la tecla oprimida, para cada protocolo o modelo diferentes asignaciones.
 
 
 
 */

- (void)SendSignalWithProtocol:(NSString*)protocol AndKeyPressed:(NSString*)KeyPressed{
    
    NSLog(@"cargamos protocolo ---> %@  key %@",protocol , KeyPressed);
    
    //Configuramos el protocolo y tecla a enviar
    [_EncodeDataIntoSignal SetProtocol:protocol AndSetKeyPressed:KeyPressed];
    
    //Enviamos el codigo dependiendo nuestra configuracion.
    [_EncodeDataIntoSignal SendDataToEmiter];



}

@end
