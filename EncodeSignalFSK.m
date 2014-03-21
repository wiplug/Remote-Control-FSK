//
//  EncodeSignalFSK.m
//  ISEL Remoto
//
//  Created by Omr on 17/03/14.
//  Copyright (c) 2014 Omr. All rights reserved.
//

#import "EncodeSignalFSK.h"


@implementation EncodeSignalFSK{
    
    float amplitude ;
    float phaseShiftInPi;
    const char* bit0;
    const char* bit1 ;
    NSString *heading ;
    NSString *tailing;
    float lowFreq;
    float highFreq;
}


const  double sampleRate = 44100;


- (id)init
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        // initialization happens here ...
        NSLog(@"se inicio encode signal");
 
        
    }
    return self;
}

- (void)initAudioSignal{
    
    /*
     //Init Sound
     
     OSStatus AudioSessionInitialize (
     
     CFRunLoopRef                      inRunLoop,
     CFStringRef                       inRunLoopMode,
     AudioSessionInterruptionListener  inInterruptionListener,
     void                              *inClientData
     
     );
     
     
     Parameters
     
     inRunLoop
     The run loop that the interruption listener callback should be run on. Pass NULL to use the main run loop.
     
     inRunLoopMode
     The mode for the run loop that the interruption listener function will run on. Passing NULL is equivalent to passing kCFRunLoopDefaultMode.
     
     inInterruptionListener
     The interruption listener callback function. The application’s audio session object invokes the callback when the session is interrupted and (if the application is still running) when the interruption ends. Can be NULL. See AudioSessionInterruptionListener.
     
     inClientData
     Data that you would like to be passed to your interruption listener callback.
     
     */
    
    
    //__bridge transfers a pointer between Objective-C and Core Foundation with no transfer of ownership.
    OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (__bridge void *)(self));
    if (result == kAudioSessionNoError)
    {
        //way to allow sounds to be played even if the ringer switch is set to off is like so
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    }

}

/*
    Configuramos el protocolo y codigo a enviar
 
 */

- (void)SetProtocol:(NSString*)protocol AndSetKeyPressed:(NSString*)keyPressed{
    
    
    _Protocol = protocol;
    _KeyValue = keyPressed;
    
}





/*
 CONFIGURACION DE PULSOS
 
 1.- BIT ALTO = 9.11   BIT BAJO = 4.53
 
 
 */


- (void)ConfigurePulseLeaderWithDataInMs:(NSString *)miliseconds{
    
    if([miliseconds isEqualToString:@"1"]){
        
        
        //Configuracion de la señal FSK
        amplitude =   1;
        //4.45ms en bajo despues del pulso lider ( 1.45 - 1 ) = 0.45Ms
         phaseShiftInPi = 1.29;
  
        heading = @"^";
        tailing = @"________________";
         lowFreq = 889;
         highFreq = 44;
    }
    
    
    
    if([miliseconds isEqualToString:@"2"]){
        
        NSLog(@"here");
        //Configuracion de la señal FSK
        amplitude =   1;
        
        //pulso con el que inicia el desplazamiento..
        phaseShiftInPi = 1.40;
        
        heading = @"^^^^^^^^^^^^^^^^^^";
        tailing = @"";
        lowFreq = 14;
        highFreq = 480;
    }
    
}



/*
    Enviamos los datos
 
 */

- (void)SendDataToEmiter{
    
    
    if (toneUnit){
		status = 0;
        AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
        if(dataQueue != NULL){
            free(dataQueue);
            dataQueue = NULL;
        }
		//[sender setTitle:NSLocalizedString(@"Send", nil) forState:0];
        
    }else{
     [self initAudioSignal];
        
    //EN USO
    status = 1;
    qIndex = 0;
        
     bit0 =  [@"_" UTF8String];
     bit1 = [@"^" UTF8String];
        
  
    
    [self ConfigurePulseLeaderWithDataInMs:@"1"];
 
 
    //Configuracion frecuencia
 
    int FrecuencyLowData = round(sampleRate/lowFreq);
    int lowSize =FrecuencyLowData*sizeof(double);
 
    int FrecuencyHighData = round(sampleRate/highFreq);
    int highSize = FrecuencyHighData*sizeof(double);
 
        
        
    //Creamos array con el tamaño de lowSteps
    double BufferForLowData[FrecuencyLowData];
    double BufferForHighData[FrecuencyHighData];
   
    
    //calcula FSK y guarda el pulso en alto en el buffer asignado BufferForLowData | BufferForHighData
    
        
    GenerateFSKEncoding(BufferForLowData, lowFreq, FrecuencyLowData, amplitude, phaseShiftInPi);
    GenerateFSKEncoding(BufferForHighData, highFreq, FrecuencyHighData, amplitude, phaseShiftInPi);
    //en este punto tenemos guardado en cada buffer el tamaño de la señal en bajo y alto.
      
    
    // CONTAMOS CUANTOS BIS SE ENVIARAN PARA PODER PARAR CUANDO SE TERMINE DE ENVIAR
    for (int i=0; i<heading.length; ++i) {
        NSString* h = [heading substringWithRange:NSMakeRange(i, 1)];
        if([h isEqualToString:@"_"]) {
            qSteps+=FrecuencyLowData;
        } else if([h isEqualToString:@"^"]) {
            qSteps+=FrecuencyHighData;
        }
    }
        
    
     // CONTAMOS CUANTOS BIS SE ENVIARAN PARA PODER PARA CUANDO SE TERMINE DE ENVIAR
 
    for (int i=0; i<tailing.length; ++i) {
        NSString* t = [tailing substringWithRange:NSMakeRange(i, 1)];
        if([t isEqualToString:@"_"]) {
            qSteps+=FrecuencyLowData;
            
        } else if([t isEqualToString:@"^"]) {
            qSteps+=FrecuencyHighData;
        }
    }
  
        
        
        
        //****************************************************************************************
        //****************************************************************************************
        //****************************************************************************************
        
        
        
        [self ConfigurePulseLeaderWithDataInMs:@"2"];
        
        
        //Configuracion frecuencia
        
        int FrecuencyLowData2 = round(sampleRate/lowFreq);
        int lowSize2 =FrecuencyLowData2*sizeof(double);
        
        int FrecuencyHighData2 = round(sampleRate/highFreq);
        int highSize2 = FrecuencyHighData2*sizeof(double);
        
        
        
        //Creamos array con el tamaño de lowSteps
        double BufferForLowData2[FrecuencyLowData2];
        double BufferForHighData2[FrecuencyHighData2];
        
        
        //calcula FSK y guarda el pulso en alto en el buffer asignado BufferForLowData | BufferForHighData
        
        
        GenerateFSKEncoding(BufferForLowData2, lowFreq, FrecuencyLowData2, amplitude, phaseShiftInPi);
        GenerateFSKEncoding(BufferForHighData2, highFreq, FrecuencyHighData2, amplitude, phaseShiftInPi);
        //en este punto tenemos guardado en cada buffer el tamaño de la señal en bajo y alto.
        
        
        // CONTAMOS CUANTOS BIS SE ENVIARAN PARA PODER PARAR CUANDO SE TERMINE DE ENVIAR
        for (int i=0; i<heading.length; ++i) {
            NSString* h = [heading substringWithRange:NSMakeRange(i, 1)];
            if([h isEqualToString:@"_"]) {
                qSteps+=FrecuencyLowData2;
            } else if([h isEqualToString:@"^"]) {
                qSteps+=FrecuencyHighData2;
            }
        }
        
        
        // CONTAMOS CUANTOS BIS SE ENVIARAN PARA PODER PARA CUANDO SE TERMINE DE ENVIAR
        
        for (int i=0; i<tailing.length; ++i) {
            NSString* t = [tailing substringWithRange:NSMakeRange(i, 1)];
            if([t isEqualToString:@"_"]) {
                qSteps+=FrecuencyLowData2;
                
            } else if([t isEqualToString:@"^"]) {
                qSteps+=FrecuencyHighData2;
            }
        }
        
        
        
        
    
         //****************************************************************************************
         //****************************************************************************************
         //****************************************************************************************
 
        //Cuantos bits se enviaran para poder parar la ejecucion cuando terminen.
        dataQueue = (double*)malloc(sizeof(double)*qSteps);
        
        PulseToSendInSignal = dataQueue;
    
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData, highSize);
        PulseToSendInSignal+=FrecuencyHighData;
   
        
        //Ingresa todos los calculos de los bits en los datos a enviar.. los bits son los que siguen del bit principar, LIDER
  
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
       
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
 
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
 
        // PULSO DISTINTO
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
 
        
        //Distinto
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        // PULSO DISTINTO BIT 1
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        
        //Distinto BIT 0
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        
        // PULSO DISTINTO BIT 1
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        
        
        //Distinto BIT 0
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        // PULSO DISTINTO BIT 1
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        
        //Distinto BIT 0
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        // PULSO DISTINTO BIT 1
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        
        
        //Distinto
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        // PULSO DISTINTO BIT 1
        
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        //Distinto
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
         //Distinto BIT 1
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        //Distinto
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, BufferForLowData, lowSize);
        PulseToSendInSignal+=FrecuencyLowData;
        
        
        //Distinto BIT 1
        //PULSO LIDER
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        memcpy(PulseToSendInSignal, BufferForHighData2, highSize2);
        PulseToSendInSignal+=FrecuencyHighData2;
        
        PulseToSendInSignal = dataQueue;
        
        
        
    
    
        [self createToneUnit];
    
    
    
    //cargamos el tono
    // Stop changing parameters on the unit
    OSErr err = AudioUnitInitialize(toneUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %d", err);
    
    //empezamos a emitir en el canal.
    // Start playback
    err = AudioOutputUnitStart(toneUnit);
    NSAssert1(err == noErr, @"Error starting unit: %d", err);
    
   
   
    }
    
    
}

/**
 
 
 Procesa y guarda todos los datos ingresados en forma de ondas a traves de FSK.
 
 @summary Calculamos cuantos bits se enviaran en total a traves de los strings - o ^ que se ingresen
 @param:  buf double lowData[lowSteps|highSteps] es el apuntador array ;
 @param:  freq Frecuencia ingresada por el usuario en campos - lowSteps o highSteps
 @param:  steps Contiene el periodo de la onda dado por round(sampleRate/lowFreq|highFreq) ejem. 441000/900 = 45
 @return: (void)
 
 **/


void GenerateFSKEncoding(double* buf, int freq, int steps, float amplitude, float phaseShiftInPi){
    
 
    double theta=0;
    
    for (int i=0; i<steps; ++i) {
        
        double theta_increment = 2.0 * M_PI * freq / sampleRate;
        
 
        buf[i] = (sin(theta+phaseShiftInPi*M_PI) * amplitude);
        
     
        theta+=theta_increment;
        
        if (theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
        
        
    }
    
 
}



/**
 
 Duerme Al hilo
 
 **/



- (void)stop
{
    
   // NSLog(@"interrumpido");
	if (toneUnit)
	{
   
		//[self sendData:[self sendButton]];
        float interval_ =  interval;
        if (interval_>0) {
            
            // Sleep for a while. This makes it easiest to test various problematic cases.
            [NSThread sleepForTimeInterval:interval/1000];
            
            
        }
        
	}
    
    //paramos de enviar la señal, pero no matamos el thread.
    [self StopSendSignal];
}




/**
 
    Summary : Callback cuando stop de emitir la señal.
 
 **/



void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	
    EncodeSignalFSK *controller = (__bridge EncodeSignalFSK*)inClientData;
    [controller stop];
    
}



/*
                    ATENCION, DEFINIR ESTA CLASE, ESTA SECCION DETIENE LA EJECICION DEL SONIDO
 
 */


- (void)StopSendSignal  {
    
    NSLog(@"paro ejecucion");
    status = 0;
    AudioOutputUnitStop(toneUnit);
    AudioUnitUninitialize(toneUnit);
    AudioComponentInstanceDispose(toneUnit);
    toneUnit = nil;
    if(dataQueue != NULL){
        free(dataQueue);
        dataQueue = NULL;
    }
        
    
}





/*
 
 // Configure the search parameters to find the default playback output unit
 // (called the kAudioUnitSubType_RemoteIO on iOS but
 // kAudioUnitSubType_DefaultOutput on Mac OS X)
 
 
 */



OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
	// Get the tone parameters out
	EncodeSignalFSK *controller = (__bridge EncodeSignalFSK*)inRefCon;
    
   
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
    //printf("Start package.\n");
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
        if(controller->status){
            
            buffer[frame] = *(controller->PulseToSendInSignal);
         
            
            ++controller->PulseToSendInSignal;
            
            // si el indicque es mayor a los Steps que tenemos que hacer entonces qu pare.
            if(++controller->qIndex >= controller->qSteps){
                
                //Invokes a method of the receiver on the main thread using the default mode.
                //printf("qIndex end:%lu qSteps:%lu\n", viewController->qIndex, viewController->qSteps);
                [controller performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];
             
                
            
                controller->status = 0;
                
              
                
                break;
                
                
            }
        }
	}
   
	return noErr;
}






- (void)createToneUnit
{
    NSLog(@"va a renderear");
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert1(toneUnit, @"Error creating unit: %d", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void *)(self);
	err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %d", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %d", err);
}






@end
