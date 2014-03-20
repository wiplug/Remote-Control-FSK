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
         phaseShiftInPi = 1.45;
  
        heading = @"^";
        tailing = @"___";
         lowFreq = 889;
         highFreq = 54;
    }
    
    
    
    if([miliseconds isEqualToString:@"2"]){
        
        NSLog(@"here");
        //Configuracion de la señal FSK
        amplitude =   1;
        
        phaseShiftInPi = 1.9;
        
        heading = @"^^^^____";
        tailing = @"";
        lowFreq = 65;
        highFreq = 889;
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
    
     bit0 =  [@"_" UTF8String];
     bit1 = [@"^" UTF8String];
        
  
    
    [self ConfigurePulseLeaderWithDataInMs:@"1"];
        
    //EN USO
    status = 1;
    qIndex = 0;
 
   
 
    //Configuracion freciuencia bajo
 
    int lowSteps = round(sampleRate/lowFreq);
    int lowSize =lowSteps*sizeof(double);
    
    //Configuracion freciuencia alto
 
    int highSteps = round(sampleRate/highFreq);
    int highSize =highSteps*sizeof(double);
    
 
    
        
        
    unsigned long bit0Steps = calcBitSteps(bit0, lowSteps, highSteps);
    unsigned long bit1Steps = calcBitSteps(bit1, lowSteps, highSteps);
        
 
    
    //Creamos array con el tamaño de lowSteps
    double lowData[lowSteps];
    //Creamos array con el tamañao de highSteps
    double highData[highSteps];
   
    
    //calcula FSK y lo guarda en el array que le estamos pasando -> lowData
        
    populateCircle(lowData, lowFreq, lowSteps, amplitude, phaseShiftInPi);
    populateCircle(highData, highFreq, highSteps, amplitude, phaseShiftInPi);
    
     
    double bit0Data[bit0Steps];
    double bit1Data[bit1Steps];
    NSLog(@" data AH ? --> %f",*bit0Data);
    getBitData(bit0, bit0Data, lowData, lowSteps, highData, highSteps);
    NSLog(@" data AH ? --> %f",*bit0Data);
    
    
    getBitData(bit1, bit1Data, lowData, lowSteps, highData, highSteps);
    
    
        
    
    // CONTAMOS CUANTOS BIS SE ENVIARAN PARA PODER PARA CUANDO SE TERMINE DE ENVIAR
    for (int i=0; i<heading.length; ++i) {
        NSString* h = [heading substringWithRange:NSMakeRange(i, 1)];
        if([h isEqualToString:@"_"]) {
            qSteps+=lowSteps;
        } else if([h isEqualToString:@"^"]) {
            qSteps+=highSteps;
        }
    }
        
    
     // CONTAMOS CUANTOS BIS SE ENVIARAN PARA PODER PARA CUANDO SE TERMINE DE ENVIAR
 
    for (int i=0; i<tailing.length; ++i) {
        NSString* t = [tailing substringWithRange:NSMakeRange(i, 1)];
        if([t isEqualToString:@"_"]) {
            qSteps+=lowSteps;
            
        } else if([t isEqualToString:@"^"]) {
            qSteps+=highSteps;
        }
    }
    
        //****************************************************************************************
        //****************************************************************************************
        //****************************************************************************************
        
        
        [self ConfigurePulseLeaderWithDataInMs:@"2"];
        
        
        
        //Configuracion freciuencia bajo
        
        int lowSteps2 = round(sampleRate/lowFreq);
        int lowSize2 = lowSteps2*sizeof(double);
        
        //Configuracion freciuencia alto
        
        int highSteps2 = round(sampleRate/highFreq);
        int highSize2 =highSteps2*sizeof(double);
        
        
        
        
        
        unsigned long bit0Steps2 = calcBitSteps(bit0, lowSteps2, highSteps2);
        unsigned long bit1Steps2 = calcBitSteps(bit1, lowSteps2, highSteps2);
        
        
        
        //Creamos array con el tamaño de lowSteps
        double lowData2[lowSteps2];
        //Creamos array con el tamañao de highSteps
        double highData2[highSteps2];
        
        
        //calcula FSK y lo guarda en el array que le estamos pasando -> lowData
        
        populateCircle(lowData2, lowFreq, lowSteps2, amplitude, phaseShiftInPi);
        populateCircle(highData2, highFreq, highSteps2, amplitude, phaseShiftInPi);
        
        
        double bit0Data2[bit0Steps2];
        double bit1Data2[bit1Steps2];
        NSLog(@" data AH ? --> %f",*bit0Data2);
        getBitData(bit0, bit0Data2, lowData2, lowSteps2, highData2, highSteps2);
        NSLog(@" data AH ? --> %f",*bit0Data2);
        
        
        getBitData(bit1, bit1Data2, lowData2, lowSteps2, highData2, highSteps2);
        
        
        
        
        // CONTAMOS CUANTOS BIS SE ENVIARAN PARA PODER PARA CUANDO SE TERMINE DE ENVIAR
        for (int i=0; i<heading.length; ++i) {
            NSString* h = [heading substringWithRange:NSMakeRange(i, 1)];
            if([h isEqualToString:@"_"]) {
                qSteps+=lowSteps2;
            } else if([h isEqualToString:@"^"]) {
                qSteps+=highSteps2;
            }
        }
        
        
        // CONTAMOS CUANTOS BIS SE ENVIARAN PARA PODER PARA CUANDO SE TERMINE DE ENVIAR
        
        for (int i=0; i<tailing.length; ++i) {
            NSString* t = [tailing substringWithRange:NSMakeRange(i, 1)];
            if([t isEqualToString:@"_"]) {
                qSteps+=lowSteps2;
                
            } else if([t isEqualToString:@"^"]) {
                qSteps+=highSteps2;
            }
        }
        
        
        //****************************************************************************************
         //****************************************************************************************
         //****************************************************************************************
 
        //Cuantos bits se enviaran para poder parar la ejecucion cuando terminen.
        dataQueue = (double*)malloc(sizeof(double)*qSteps);
        
        PulseToSendInSignal = dataQueue;
    
        //PULSO LIDER
        memcpy(PulseToSendInSignal, highData, highSize);
        PulseToSendInSignal+=highSteps;
   
        
        //Ingresa todos los calculos de los bits en los datos a enviar.. los bits son los que siguen del bit principar, LIDER
  
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, lowData, lowSize);
        PulseToSendInSignal+=lowSteps;
        
        
        
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, lowData, lowSize);
        PulseToSendInSignal+=lowSteps;
 
        
        //BIT_0 = Alto = 598 Bajo = 534
        memcpy(PulseToSendInSignal, lowData, lowSize);
        PulseToSendInSignal+=lowSteps;
        
        
        
    
        
        //BIT 1
        memcpy(PulseToSendInSignal, highData2, highSize2);
        PulseToSendInSignal+=highSteps2;
        
        
        //BIT 0
        memcpy(PulseToSendInSignal, lowData2, lowSize2);
        PulseToSendInSignal+=lowSize2;
  
        
      
        
  
        
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
 
 
 @summary:
 @param:   bit         Contiene como string los siguientes datos  _ | ^
 @param:   data        Los datos en array ?
 @param:   lowData     Los datos en array ?  double data[lowSteps|highSteps] =  Contiene el periodo en bajo definido por  round(sampleRate/lowFreq) ejem. 441000/900 = 45
 @param:   lowSteps    La frecuencia en bajo dado por round(sampleRate/lowFreq);
 @param:   highData    double data[lowSteps|highSteps] =  Contiene el periodo en bajo|alto definido por   round(sampleRate/highFreq);
 @param:   highSteps   La frecuencia en alto dado por round(sampleRate/lowFreq);
 @return   (void)
 
 **/

void getBitData(const char* bit, double* data, const double* lowData,int lowSteps, const double* highData, int highSteps){
    
    
    for(int i=0;i<strlen(bit);++i){
        
        char c = bit[i];
        
        if(c == '_'){
            
            //copia los primeros n caracteres del objeto apuntado por s2 al objeto apuntado por s1.
            //void *memcpy(void *s1, const void *s2, size_t n);
            memcpy(data, lowData, lowSteps*sizeof(double));
            data+=lowSteps;
            
            
        }else if(c == '^'){
            
            memcpy(data, highData, highSteps*sizeof(double));
            data+=highSteps;
            
        }
        
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


void populateCircle(double* buf, int freq, int steps, float amplitude, float phaseShiftInPi){
    
    //NSLog(@"buf  %f",buf[0]);
    
    //Tiempo
    double theta=0;
    
    for (int i=0; i<steps; ++i) {
        
        double theta_increment = 2.0 * M_PI * freq / sampleRate;
        
        //enviamos desplazamiento por PI
        buf[i] = (sin(theta+phaseShiftInPi*M_PI) * amplitude);
        
        //NSLog(@"emmiting ->%f",buf[i]);
        theta+=theta_increment;
        
        if (theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
        
        
    }
    
    //NSLog(@"buf  %f",buf[1]);
}






/**
 
 Calcula cuantos bits hay que enviar , cuantos bits fueron ingresados a traves de Chars o Strings.
 
 @summary Calculamos cuantos bits se enviaran en total a traves de los strings - o ^ que se ingresen
 @param:  bit  Contiene como string los siguientes datos  _ | ^
 @param:  lowSteps Contiene el periodo en bajo definido por  round(sampleRate/lowFreq) ejem. 441000/900 = 45
 @param:  highStep Contiene el periodo en alto definido por round(sampleRate/highFreq)
 @return: La cuenta total de desplazamientos dependiendo el bit ingresado.
 
 **/


unsigned long calcBitSteps(const char* bit, int lowSteps, int highSteps){
    unsigned long TotalTimePhasePerBit = 0;
    for(int i=0;i<strlen(bit);++i){
        char c = bit[i];
        if(c == '_'){
            TotalTimePhasePerBit+=lowSteps;
        }else if(c == '^'){
            TotalTimePhasePerBit+=highSteps;
        }
    }
    
    return TotalTimePhasePerBit;
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
            //printf("qIndex:%lu, frame:%d, value:%f\n", viewController->qIndex, (unsigned int)frame, *(viewController->opDq));
            
            
              //NSLog(@"qIndex:%lu, frame:%d, value:%f\n", controller->qIndex, (unsigned int)frame, *(controller->opDq));
            
            
            
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
