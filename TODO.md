# List of planned improvements

This is a draft TODO list for future directions in zenroom
development, to be vouched with priorities emerging from DECODE pilots
and their specific use-cases.

-faddress-sanitizers <- (check flags)


## Deterministic Random in the Checker

how to be sure that code executes on any computer and that the answer
is correct

if i give someone a contract and get a result how can I be sure that
has been computed/executed correctly

a solution can be to make it done by many....

the only random useful in EC are numbers in FP
and the FP is already modulus so smaller than the order



the only random needed is for generation of the private key
the private key is a random number smaller than the order of the curve
the public key is the scalar multiplication between G1 and the private key
(all public keys have this procedure)
this should work also in G2

the scalars that are multiplied to G1 and G2 need to be random

the ecp1 and ecp2 functions for _mul are there and side-channel resistant
so the only needed thing needed is the generation of a big number


(optimisation)
G1 and G2 multiplications can be done using pairing functions
that optimise using endomorphism
see: `void PAIR_BLS383_G1mul(ECP_BLS383 *P,BIG_384_29 e)`

## Coconut notes

useful to have a functio that does PAIR:ate and PAIR:fexp on the same ECP2
also ate() can be called miller_loop and miller() and loop()
FP12 = pair(ECP1, ECP2)
then FP12 equals is the only thing needed


```
require'ecp'
mypoint = ecp.hash_to_point(octet)
mynewbig = big.hash_to_big(13123,123123213,2334)
mypoint = ecp.hash(octet)
mynewbig = big.hash(1213123213,1221232141,123213324)
!! hash_to_big has variadic arguments !!

```
hash_to_point:
function that takes any octet string
hashes it with any hashing algorithm
does a mapit to place it on the curve

hash_to_big:
very useful to have
a hash function that takes a series of big numbers
and outputs a big number
the big number series can be simply concatenated
and then hashed as a series of bytes


expose G1 as fixed ECP point
expose G2 as fixed ECP2 point
i.e.
/* Generator point on G1 */
extern const BIG_384_29 CURVE_Gx_BLS383; /**< x-coordinate of generator point in group G1  */
extern const BIG_384_29 CURVE_Gy_BLS383; /**< y-coordinate of generator point in group G1  */
should become a const ECP 

about DBIG: no need to expose
they result from big multiplications between big numbers
but there is never a real use, because all useful multiplications have a modulus applied

every FP is also a BIG
but not every BIG is also an FP
exporting in BIG is more interesting since it can be of any size
and can be reduced to FP to match the curve

each curve has a different infinity point

TODO: do all ecp2 (new namespace)

TODO: pair.h 
extern void PAIR_ZZZ_fexp(FP12_YYY *x);
extern void PAIR_ZZZ_ate(FP12_YYY *r,ECP2_ZZZ *P,ECP_ZZZ *Q);
possibly extern int PAIR_ZZZ_GTmember(FP12_YYY *x);
!!!!
FP12_YYY is exactly twice as big of the FP1 of the curve
so its made of two BIGs and can be a tuple

TODO: big numbers operations
	in particular BIG_XXX_mod*

DONE:
infinity production for "EC generator"
test:
O = infinity point
P + O = P
(-P) + P = O
DONE:
to expose the order of the curve:
like in rom_curve_XXX:
const BIG_256_29 CURVE_Order_ED25519= {0x1CF5D3ED,0x9318D2,0x1DE73596,0x1DF3BD45,0x14D,0x0,0x0,0x0,0x100000};
test:
multiply group order by the generetor should give the point at infinity

## Generic improvements

- parse lib/milagro-crypto-c/cmake/AMCLParameters.cmake for info about
  curves: size of BIG, names and pairing-friendliness

- add brieflz2 compression

- add more memory tracking / fencing facilities also for script
  testing/profiling
	  https://github.com/kallisti5/ElectricFence
	  https://github.com/Ryandev/MemoryTracker


- add tracking of single lua command/operations executions

- in/out to MSGPACK in addition to JSON for compact messaging easy using
  Antirez' extension see https://github.com/antirez/lua-cmsgpack

- add some more functions from stdlib's string and utils
  https://github.com/lua-stdlib/lua-stdlib

- Include libs from penlight
  http://stevedonovan.github.io/Penlight/api/index.html stringx, lexer

- erlang style pattern matching on data structures
  https://github.com/silentbicycle/tamale

- date and time module
  https://github.com/Tieske/date

V if event based callback framework needed, try including libev
  https://github.com/brimworks/lua-ev
  http://software.schmorp.de/pkg/libev.html

V pick extensions from here
  http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/

X compile extensions and load them from strings using the lua load()
  function directly with callbacks
  http://www.lua.org/manual/5.1/manual.html#lua_load

X provide a finite state machine programming interface
  https://github.com/kyleconroy/lua-state-machine
  https://github.com/airstruck/knife/blob/master/readme/behavior.md

X functional programming facility
  https://github.com/Yonaba/Moses

X use static memory pool in place of malloc from host
  https://github.com/dcshi/ncx_mempool
  implemented using umm_malloc

V add a new 8bit memory manager to test
  https://github.com/8devices/MemoryManager perhaps also build a
  memory paging system to use 8bit mm over larger portions of memory

## Developer experience

- on error print out code at line where it has been detected
  the line number is already included between semicolons
  just need to go to script buffer and extract line

- !! make a Jupyter kernel for zenroom (-> Puria)
  - http://jupyter-client.readthedocs.io/en/latest/kernels.html
  - https://github.com/neomantra/lua_ipython_kernel

- graphviz representation of complex data structures
  http://siffiejoe.github.io/lua-microscope/

- add superior testing and profiling facility with lust
  https://github.com/bjornbytes/lust

- enhance debug module stacktrace
  https://github.com/ignacio/StackTracePlus

V introspection (now made with AST output)
  https://github.com/leegao/see.lua

V self documentation
  https://github.com/rgieseke/locco
  (also includes interesting modules as luabalanced)

X add list of functions and keywords for completion in ace
  the js editor used for the example. last review of way
  to include extensions (with prefix. or?)

## Performance

- Benchmark suite to measure capacity to de/code large amounts of
  streaming data in chunks.

V Investigate adoption of LuaJit in place of Lua5.1
  (should be easy as it seems the C api is pretty much the same)

## Security

- maybe support Linux kernel keystore feature for loaded keys
  (see cryptsetup 2.0)

X adopt a declarative approach to data schemes accepted in scripts
  supporting i.e. https://github.com/sschoener/lua-schema
  code analysis to report on bad constructs
  DONE - just write documentation, examples and tests

## Documentation

- Start sketching an high-level API based on experience in DECODE

- Provide cross-language examples for most basic operations

V Make it easy to integrate with BLOCKLY to generate simple
  cryptographic functions.

X Build a simple example webpage that runs only in javascript and
  compiles Zenroom scripts providing results

X Document api with luadoc http://keplerproject.github.io/luadoc/
  or other means http://lua-users.org/wiki/DocumentingLuaCode

## Crypto

- see if ECDAA is any useful https://github.com/xaptum/ecdaa
  has Direct Anonymous Attestation (DAA) and Schnorr sigs

- Build a usable ABC implementation (maybe compatible with coconut
  and/or IRMA?)

- Reproduce tor's new onion address scheme
  (see tor-dam/pkg/damlib/crypto_25519.go)

- Consider adding GOST from https://github.com/aprelev/libgost15

- Investigate inclusion of primitives from libsodium

- Investigate inclusion of primitives from libgcrypt

- Investigate strategies to build compatibility with ssh

- Investigate strategies to build compatibility with gnupg

X Integrate the new secret-sharing library by dsprenkels

- Include salsa20 (and its dependency bit32)

X Finish integrating Milagro in the LUA script

## Parser

This section lists hypotethical developments and may lead to a
completely new release of Zenroom or a derivate, while keeping the LUA
one still maintained

? Substitute cjson with a langsec hammer parser (tutorial lesson13)

? After extensive documentation of use-cases, substitute the LUA
  syntax parser with a limited DSL also written in langsec hammer

- Add SMT analysis as a backend to most sensitive operations
