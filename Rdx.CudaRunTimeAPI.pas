unit Rdx.CudaRunTimeAPI;


interface

uses
  Windows, SysUtils, Rdx.CudaDriverTypes;

type
 {$MinEnumSize 4} // Збільште розмір для сумісності C++.
 TCudaMemcpyKind = (cmkHostToHost = 0, cmkHostToDevice, cmkDeviceToHost,
    cmkDeviceToDevice);
 {$MinEnumSize 1} // Відновлення за замовчуванням.

  /// //////////////////////////////////////
  // Allocate Memory Function Prototypes //
  /// //////////////////////////////////////

  TCudaMalloc = function(var GpuMemoryPtr: Pointer;  Size: Cardinal): TCudaError; stdcall;
  TCudaMallocHost = function(var Ptr: Pointer; Size: Cardinal): TCudaError;    stdcall;
  TCudaFree = function(GpuMemoryPtr: Pointer): TCudaError; stdcall;
  TCudaFreeHost = function(Ptr: Pointer): TCudaError; stdcall;

  /// //////////////////////////////
  // MemCopy Function Prototypes //
  /// //////////////////////////////

  TCudaMemcpy = function(Dest: Pointer; const Source: Pointer; Count: Cardinal;
    Kind: TCudaMemcpyKind): TCudaError; stdcall;

var
  cudaMalloc:     TCudaMalloc;
  cudaMallocHost: TCudaMallocHost;
  cudaFree:       TCudaFree;
  cudaFreeHost:   TCudaFreeHost;
  cudaMemcpy:     TCudaMemcpy;


var
  CudaRuntimeLoaded: Boolean;

implementation

var
  CudaRuntimeDLL: HMODULE;

const
  CCudaRuntimeDLLName = 'cudart64_110.dll';

procedure InitializeCudaRuntimeLibrary;
begin
  CudaRuntimeDLL := LoadLibraryEx(CCudaRuntimeDLLName, 0, 0);
  if CudaRuntimeDLL = 0 then
    raise Exception.CreateFmt('File: %s could not be found',
      [CCudaRuntimeDLLName])
  else
  begin
    CudaRuntimeLoaded := True;
    @cudaMalloc     := GetProcAddress(CudaRuntimeDLL, 'cudaMalloc');   Assert(@cudaMalloc <> nil);
    @cudaMallocHost := GetProcAddress(CudaRuntimeDLL, 'cudaMallocHost');  Assert(@cudaMallocHost <> nil);
    @cudaFree       := GetProcAddress(CudaRuntimeDLL, 'cudaFree');       Assert(@cudaFree <> nil);
    @cudaFreeHost   := GetProcAddress(CudaRuntimeDLL, 'cudaFreeHost');   Assert(@cudaFreeHost <> nil);
    @cudaMemcpy     := GetProcAddress(CudaRuntimeDLL, 'cudaMemcpy');     Assert(@cudaMemcpy <> nil);
  end;
end;

procedure FinalizeCudaRuntimeLibrary;
begin
  FreeLibrary(CudaRuntimeDLL);
  CudaRuntimeLoaded := False;
end;

initialization

InitializeCudaRuntimeLibrary;


finalization

FinalizeCudaRuntimeLibrary;

end.

