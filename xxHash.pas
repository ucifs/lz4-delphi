////////////////// xxHash.h binding file /////////////////////
/// Version: r36
/// Author: Hanno Hugenberg

{
   xxHash - Fast Hash algorithm
   Header File
   Copyright (C) 2012-2014, Yann Collet.
   BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

       * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
       * Redistributions in binary form must reproduce the above
   copyright notice, this list of conditions and the following disclaimer
   in the documentation and/or other materials provided with the
   distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   You can contact the author at :
   - xxHash source repository : http://code.google.com/p/xxhash/
}

{
  Notice extracted from xxHash homepage :

  xxHash is an extremely fast Hash algorithm, running at RAM speed limits.
  It also successfully passes all tests from the SMHasher suite.

  Comparison (single thread, Windows Seven 32 bits, using SMHasher on a Core 2 Duo @3GHz)

  Name            Speed       Q.Score   Author
  xxHash          5.4 GB/s     10
  CrapWow         3.2 GB/s      2       Andrew
  MumurHash 3a    2.7 GB/s     10       Austin Appleby
  SpookyHash      2.0 GB/s     10       Bob Jenkins
  SBox            1.4 GB/s      9       Bret Mulvey
  Lookup3         1.2 GB/s      9       Bob Jenkins
  SuperFastHash   1.2 GB/s      1       Paul Hsieh
  CityHash64      1.05 GB/s    10       Pike & Alakuijala
  FNV             0.55 GB/s     5       Fowler, Noll, Vo
  CRC32           0.43 GB/s     9
  MD5-32          0.33 GB/s    10       Ronald L. Rivest
  SHA1-32         0.28 GB/s    10

  Q.Score is a measure of quality of the hash function.
  It depends on successfully passing SMHasher test set.
  10 is a perfect score.
}

unit xxHash;

{$I lz4d.defines.inc}

interface

// bind necessary object files

// * MinGW * //
{$IfDef MinGW_LIB}
  {$L lib/win32_mingw/xxhash.o}
{$EndIf}


// * Visual Studio * //
{$IfDef VS_LIB}
  {$L lib/win32_vs/xxhash.obj}
{$EndIf}

/// Linking lz4 object files and adding dependencies
/// - linking the object files produces additional dependencies
///    which would be usaly provided by the object file linker
///  - see dependency units for more informations

{$IfDef ResolveMissingDependencies}
uses
  lz4d.dependencies;
{$Else}

{$Endif}



//****************************
// Type
//****************************
type XXH_errorcode = ( XXH_OK=0, XXH_ERROR ) ;

//****************************
// Simple Hash Functions
//****************************

//XXH32() :
//    Calculate the 32-bits hash of sequence of length "len" stored at memory address "input".
//    The memory between input & input+len must be valid (allocated and read-accessible).
//    "seed" can be used to alter the result predictably.
//    This function successfully passes all SMHasher tests.
//    Speed on Core 2 Duo @ 3 GHz (single thread, SMHasher benchmark) : 5.4 GB/s
//    Note that "len" is type "int", which means it is limited to 2^31-1.
//    If your data is larger, use the advanced functions below.
//XXH64() :
//    Calculate the 64-bits hash of sequence of length "len" stored at memory address "input".


//Compiler error:
// [dcc32 Fehler] xxHash.pas(118): E2065 Ungenügende Forward- oder External-Deklaration: 'XXH32'

function XXH32 (const AInput: Pointer; ALength: Integer; ASeed: Cardinal):  Cardinal; cdecl; external name '_XXH32';
function XXH64 (const AInput: Pointer; ALength: Integer; ASeed: UInt64):    UInt64;   cdecl; external name '_XXH64';

//****************************
// Advanced Hash Functions
//****************************

//These functions calculate the xxhash of an input provided in several small packets,
//as opposed to an input provided as a single block.
//
//It must be started with :
//void* XXHnn_init()
//The function returns a pointer which holds the state of calculation.
//
//This pointer must be provided as "void* state" parameter for XXH32_update().
//XXHnn_update() can be called as many times as necessary.
//The user must provide a valid (allocated) input.
//The function returns an error code, with 0 meaning OK, and any other value meaning there is an error.
//Note that "len" is type "int", which means it is limited to 2^31-1.
//If your data is larger, it is recommended to chunk your data into blocks
//of size for example 2^30 (1GB) to avoid any "int" overflow issue.
//
//Finally, you can end the calculation anytime, by using XXHnn_digest().
//This function returns the final nn-bits hash.
//You must provide the same "void* state" parameter created by XXHnn_init().
//Memory will be freed by XXHnn_digest().

function XXH32_init   (ASeed: Cardinal): Pointer; cdecl; external name '_XXH32_init';
function XXH32_update (const AState, AInput: Pointer; ALength: Integer): XXH_errorcode; cdecl; external name '_XXH32_update';
function XXH32_digest (const AState: Pointer): Cardinal; cdecl; external name '_XXH32_digest';


function XXH64_init   (ASeed: UInt64): Pointer; cdecl; external name '_XXH64_init';
function XXH64_update (const AState, AInput: Pointer; ALength: Integer): XXH_errorcode; cdecl; external name '_XXH64_update';
function XXH64_digest (const AState: Pointer): UInt64; cdecl; external name '_XXH64_digest';

//These functions allow user application to make its own allocation for state.
//
//XXHnn_sizeofState() is used to know how much space must be allocated for the xxHash nn-bits state.
//Note that the state must be aligned to access 'long long' fields. Memory must be allocated and referenced by a pointer.
//This pointer must then be provided as 'state' into XXHnn_resetState(), which initializes the state.
//
//For static allocation purposes (such as allocation on stack, or freestanding systems without malloc()),
//use the structure XXHnn_stateSpace_t, which will ensure that memory space is large enough and correctly aligned to access 'long long' fields.

function XXH32_sizeofState(): Integer; cdecl; external name '_XXH32_sizeofState';
function XXH32_resetState(AState: Pointer; ASeed: Cardinal): XXH_errorcode; cdecl; external name '_XXH32_resetState';

//#define       XXH32_SIZEOFSTATE 48
//typedef struct { long long ll[(XXH32_SIZEOFSTATE+(sizeof(long long)-1))/sizeof(long long)]; } XXH32_stateSpace_t;

function XXH64_sizeofState(): Integer; cdecl; external name '_XXH64_sizeofState';
function XXH64_resetState(AState: Pointer; ASeed: Cardinal): XXH_errorcode; cdecl; external name '_XXH64_resetState';

//#define       XXH64_SIZEOFSTATE 88
//typedef struct { long long ll[(XXH64_SIZEOFSTATE+(sizeof(long long)-1))/sizeof(long long)]; } XXH64_stateSpace_t;


//This function does the same as XXHnn_digest(), generating a nn-bit hash,
//but preserve memory context.
//This way, it becomes possible to generate intermediate hashes, and then continue feeding data with XXHnn_update().
//To free memory context, use XXHnn_digest(), or free().

function XXH32_intermediateDigest( AState: Pointer): Cardinal; cdecl; external name '_XXH32_intermediateDigest';
function XXH64_intermediateDigest( AState: Pointer): Cardinal; cdecl; external name '_XXH64_intermediateDigest';


implementation

end.
