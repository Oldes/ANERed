#if defined(WIN32)
	#define _CRT_SECURE_NO_WARNINGS
	#define EXPORT __declspec( dllexport ) 
	#include <windows.h>
	//#include <stdio.h>
	//#include <stdlib.h>
	#include <string.h>
	#include "FlashRuntimeExtensions.h"
#else
	// Symbols tagged with EXPORT are externally visible.
	// Must use the -fvisibility=hidden gcc option.
	#define EXPORT __attribute__((visibility("default"))) 
	#include <Foundation/Foundation.h>
	#include <Adobe AIR/Adobe AIR.h>
#endif


extern "C" {
	FREObject ANERed_Init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	FREObject ANERed_Hello(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

    // A native context instance is created
    void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                            uint32_t* numFunctions, const FRENamedFunction** functions);
    void ContextFinalizer(FREContext ctx);
    EXPORT void ExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                               FREContextFinalizer* ctxFinalizerToSet);
    EXPORT void ExtFinalizer(void* extData);
}
