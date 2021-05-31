unit Rdx.CudaRand;

interface

type
 TCurandGenerator_st = packed record
 end;
// TCurandGenerator_st = record
// end;
 PCurandGenerator_st = ^TCurandGenerator_st;
 PPCurandGenerator_st = ^PCurandGenerator_st;


{$MinEnumSize 4} // Збільште розмір для сумісності C++.

 TCurandRngType = (
    CURAND_RNG_TEST = 0,
    CURAND_RNG_PSEUDO_DEFAULT = 100, ///< Default pseudorandom generator
    CURAND_RNG_PSEUDO_XORWOW = 101, ///< XORWOW pseudorandom generator
    CURAND_RNG_PSEUDO_MRG32K3A = 121, ///< MRG32k3a pseudorandom generator
    CURAND_RNG_PSEUDO_MTGP32 = 141, ///< Mersenne Twister MTGP32 pseudorandom generator
    CURAND_RNG_PSEUDO_MT19937 = 142, ///< Mersenne Twister MT19937 pseudorandom generator
    CURAND_RNG_PSEUDO_PHILOX4_32_10 = 161, ///< PHILOX-4x32-10 pseudorandom generator
    CURAND_RNG_QUASI_DEFAULT = 200, ///< Default quasirandom generator
    CURAND_RNG_QUASI_SOBOL32 = 201, ///< Sobol32 quasirandom generator
    CURAND_RNG_QUASI_SCRAMBLED_SOBOL32 = 202,  ///< Scrambled Sobol32 quasirandom generator
    CURAND_RNG_QUASI_SOBOL64 = 203, ///< Sobol64 quasirandom generator
    CURAND_RNG_QUASI_SCRAMBLED_SOBOL64 = 204  ///< Scrambled Sobol64 quasirandom generator
);


TCurandStatus = (
    CURAND_STATUS_SUCCESS = 0, ///< No errors
    CURAND_STATUS_VERSION_MISMATCH = 100, ///< Header file and linked library version do not match
    CURAND_STATUS_NOT_INITIALIZED = 101, ///< Generator not initialized
    CURAND_STATUS_ALLOCATION_FAILED = 102, ///< Memory allocation failed
    CURAND_STATUS_TYPE_ERROR = 103, ///< Generator is wrong type
    CURAND_STATUS_OUT_OF_RANGE = 104, ///< Argument out of range
    CURAND_STATUS_LENGTH_NOT_MULTIPLE = 105, ///< Length requested is not a multple of dimension
    CURAND_STATUS_DOUBLE_PRECISION_REQUIRED = 106, ///< GPU does not have double precision required by MRG32k3a
    CURAND_STATUS_LAUNCH_FAILURE = 201, ///< Kernel launch failure
    CURAND_STATUS_PREEXISTING_FAILURE = 202, ///< Preexisting failure on library entry
    CURAND_STATUS_INITIALIZATION_FAILED = 203, ///< Initialization of CUDA failed
    CURAND_STATUS_ARCH_MISMATCH = 204, ///< Architecture mismatch, GPU does not support requested feature
    CURAND_STATUS_INTERNAL_ERROR = 999 ///< Internal library error
);

{$MinEnumSize 1} // Відновлення за замовчуванням.




  __TcurandCreateGenerator = function(generator: PPCurandGenerator_st; rng_type: TCurandRngType): TCurandStatus;
  __TcurandSetPseudoRandomGeneratorSeed = function(generator: PCurandGenerator_st; seed: UInt64): TCurandStatus;
  __TcurandGenerateNormal = function(generator: PCurandGenerator_st; outputPtr: PSingle; n: UInt64; mean: Single; stddev: Single): TCurandStatus;
  __TcurandDestroyGenerator = function(generator: PCurandGenerator_st): TCurandStatus;
var
  curandCreateGenerator:              __TcurandCreateGenerator;
  curandSetPseudoRandomGeneratorSeed: __TcurandSetPseudoRandomGeneratorSeed;
  curandGenerateNormal:               __TcurandGenerateNormal;
  curandDestroyGenerator:             __TcurandDestroyGenerator;


implementation

uses
  Winapi.Windows, System.SysUtils;

var
  CudaRandDLL: HMODULE;
  CudaRandLoaded: boolean;



const
  CudaRandDLLName = 'curand64_10.dll';

procedure InitializeCudaRandLibrary;
begin
  CudaRandDLL := LoadLibraryEx(CudaRandDLLName, 0, 0);
  if CudaRandDLL = 0 then
    raise Exception.CreateFmt('File: %s could not be found',
      [CudaRandDLLName])
  else
  begin
    CudaRandLoaded := True;

    @curandCreateGenerator := GetProcAddress(CudaRandDLL, 'curandCreateGenerator');  Assert ( @curandCreateGenerator <> nil);
    @curandSetPseudoRandomGeneratorSeed := GetProcAddress(CudaRandDLL, 'curandSetPseudoRandomGeneratorSeed'); Assert ( @curandSetPseudoRandomGeneratorSeed <> nil);
    @curandGenerateNormal := GetProcAddress(CudaRandDLL, 'curandGenerateNormal'); Assert ( @curandSetPseudoRandomGeneratorSeed <> nil);
    @curandDestroyGenerator := GetProcAddress(CudaRandDLL, 'curandDestroyGenerator'); Assert(@curandDestroyGenerator <> nil);
  end;

end;

procedure FinalizeCudaRandLibrary;
begin
  FreeLibrary(CudaRandDLL);
  CudaRandLoaded := False;
end;

initialization
  InitializeCudaRandLibrary();


finalization
  FinalizeCudaRandLibrary();



end.
