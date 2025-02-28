USING: alien.accessors alien.c-types alien.libraries
alien.strings alien.syntax byte-arrays cpu.x86 eval help.markup
help.syntax io io.backend io.encodings.utf16 io.encodings.utf8
kernel math quotations sequences system ;
IN: alien

HELP: callee-cleanup?
{ $values { "abi" abi } { "?" boolean } }
{ $description { $link t } " if the calling convention is callee cleanup." } ;

HELP: cdecl
{ $description "This symbol is passed as the " { $snippet "abi" } " argument to " { $link alien-indirect } ", " { $link alien-callback } ", " { $link alien-assembly } ", and " { $link add-library } " to indicate that the standard C calling convention should be used, where the caller cleans up the stack frame after calling the function. This symbol only has meaning on 32-bit x86 platforms." } ;

HELP: callsite-not-compiled
{ $error-description "Thrown if the word calling the given word was not compiled with the optimizing compiler. This can happen when experimenting with the word in this listener. To fix the problem, place the word call in a word; word definitions are automatically compiled with the optimizing compiler. Only a few words relating to calling FFI functions throws this error." } ;

HELP: stdcall
{ $description "This symbol is passed as the " { $snippet "abi" } " argument to " { $link alien-indirect } ", " { $link alien-callback } ", " { $link alien-assembly } ", and " { $link add-library } " to indicate that the Windows API calling convention should be used, where the called function cleans up its own stack frame before returning to the caller. This symbol only has meaning on 32-bit x86 platforms." } ;

HELP: fastcall
{ $warning "In the current implementation this ABI only works for functions that take only integer and pointer arguments." }
{ $description "This symbol is passed as the " { $snippet "abi" } " argument to " { $link alien-indirect } ", " { $link alien-callback } ", " { $link alien-assembly } ", and " { $link add-library } " to indicate that the \"fast call\" calling convention should be used, where the first two integer or pointer arguments are passed in registers and the function cleans up its own stack frame before returning to the caller. This symbol only has meaning on 32-bit x86 platforms." } ;

HELP: thiscall
{ $description "This symbol is passed as the " { $snippet "abi" } " argument to " { $link alien-indirect } ", " { $link alien-callback } ", " { $link alien-assembly } ", and " { $link add-library } " to indicate that Microsoft Visual C++ calling convention should be used, where the first argument (which must be a \"this\" pointer) is passed in a register and the function cleans up its own stack frame before returning to the caller. This symbol only has meaning on 32-bit x86 platforms." } ;

{ cdecl stdcall fastcall thiscall } related-words

HELP: >c-ptr
{ $values { "obj" object } { "c-ptr" c-ptr } }
{ $contract "Outputs a pointer to the binary data of this object." } ;

HELP: byte-length
{ $values { "obj" object } { "n" "a non-negative integer" } }
{ $contract "Outputs the number of bytes of binary data that will be output by " { $link >c-ptr } "." } ;

HELP: element-size
{ $values { "seq" sequence } { "n" "a non-negative integer" } }
{ $contract "Outputs the number of bytes used for each element of the sequence." }
{ $notes "If a sequence class implements " { $link element-size } " and " { $link >c-ptr } ", then instances of this sequence, as well as slices of this sequence, can be used as binary objects." } ;

{ >c-ptr element-size byte-length } related-words

HELP: alien
{ $class-description "The class of alien pointers. See " { $link "syntax-aliens" } " for syntax and " { $link "c-data" } " for general information." } ;

HELP: dll
{ $class-description "The class of native library handles. See " { $link "syntax-aliens" } " for syntax and " { $link "dll.private" } " for general information."
$nl
"The dll tuple has one slot 'path' which holds the filesystem path to the library being loaded in the systems " { $link native-string-encoding } ", usually " { $link utf8 } " on unices and " { $link utf16n } " on windows." } ;

HELP: dll-valid?
{ $values { "dll" dll } { "?" boolean } }
{ $description "Returns true if the library exists and is loaded." } ;

HELP: expired?
{ $values { "c-ptr" c-ptr } { "?" boolean } }
{ $description "Tests if the alien is a relic from an earlier session. A byte array is never considered to have expired, whereas passing " { $link f } " always yields true." } ;

HELP: <bad-alien>
{ $values { "alien" c-ptr } }
{ $description "Constructs an invalid alien pointer that has expired." } ;

HELP: <displaced-alien>
{ $values { "displacement" integer } { "c-ptr" c-ptr } { "alien" "a new alien" } }
{ $description "Creates a new alien address object, wrapping a raw memory address. The alien points to a location in memory which is offset by " { $snippet "displacement" } " from the address of " { $snippet "c-ptr" } "." }
{ $notes "Passing a value of " { $link f } " for " { $snippet "c-ptr" } " creates an alien with an absolute address; this is how " { $link <alien> } " is implemented."
$nl
"Passing a zero absolute address does not construct a new alien object, but instead makes the word output " { $link f } "." } ;

{ <alien> <displaced-alien> alien-address } related-words

HELP: free-callback
{ $values { "alien" alien } }
{ $description "Releases the callback heap memory allocated for an alien callback." }
{ $warning "If the callback is invoked (either from C or Factor) after it has been freed, then Factor may crash." } ;

HELP: with-callback
{ $values { "alien" alien } { "quot" quotation } }
{ $description "Calls the quotation with an alien value on the stack which is supposed to be a callback. Resources for the callback is guaranteed to be released afterwards." } ;

{ <callback> free-callback unregister-and-free-callback with-callback } related-words

HELP: alien-address
{ $values { "c-ptr" c-ptr } { "addr" "a non-negative integer" } }
{ $description "Outputs the address of an alien." }
{ $notes "Taking the address of a " { $link byte-array } " is explicitly prohibited since byte arrays can be moved by the garbage collector between the time the address is taken, and when it is accessed. If you need to pass pointers to C functions which will persist across alien calls, you must allocate unmanaged memory instead. See " { $link "malloc" } "." } ;

HELP: <alien>
{ $values { "address" "a non-negative integer" } { "alien" "a new alien address" } }
{ $description "Creates an alien object, wrapping a raw memory address." }
{ $notes "Alien objects are invalidated between image saves and loads." } ;

HELP: c-ptr
{ $class-description "Class of objects consisting of aliens, byte arrays and " { $link f } ". These objects all can be used as values of " { $link pointer } " C types." } ;

HELP: alien-invoke
{ $values { "args..." "zero or more objects passed to the C function" } { "return" "a C return type" } { "library" "a logical library name" } { "function" "a C function name" } { "parameters" "a sequence of C parameter types" } { "varargs?" boolean } { "return..." "the return value of the function, if not " { $link void } } }
{ $description "Calls a C library function with the given name. Input parameters are taken from the data stack, and the return value is pushed on the data stack after the function returns. A return type of " { $link void } " indicates that no value is to be expected." }
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $errors "Throws an " { $link callsite-not-compiled } " if the word calling " { $link alien-invoke } " was not compiled with the optimizing compiler." } ;

HELP: alien-indirect
{ $values { "args..." "zero or more objects passed to the C function" } { "funcptr" "a C function pointer" } { "return" "a C return type" } { "parameters" "a sequence of C parameter types" } { "abi" "one of " { $link cdecl } " or " { $link stdcall } } { "return..." "the return value of the function, if not " { $link void } } }
{ $description
    "Invokes a C function pointer passed on the data stack. Input parameters are taken from the data stack following the function pointer, and the return value is pushed on the data stack after the function returns. A return type of " { $link void } " indicates that no value is to be expected."
}
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $errors "Throws an " { $link callsite-not-compiled } " if the word calling " { $link alien-indirect } " is not compiled." } ;

HELP: alien-callback
{ $values { "return" "a C return type" } { "parameters" "a sequence of C parameter types" } { "abi" "one of " { $link cdecl } " or " { $link stdcall } } { "quot" quotation } { "alien" alien } }
{ $description
    "Defines a callback from C to Factor which accepts the given set of parameters from the C caller, pushes them on the data stack, calls the quotation, and passes a return value back to the C caller. A return type of " { $snippet "void" } " indicates that no value is to be returned."
    $nl
    "When a compiled reference to this word is called, it pushes the callback's alien address on the data stack. This address can be passed to any C function expecting a C function pointer with the correct signature. The callback is actually generated when the word calling " { $link alien-callback } " is compiled."
    $nl
    "Callback quotations run with freshly-allocated stacks. This means the data stack contains the values passed by the C function, and nothing else. It also means that if the callback throws an error which is not caught, the Factor runtime will halt. See " { $link "errors" } " for error handling options."
}
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $examples
    "A simple example, showing a C function which returns the difference of two given integers:"
    { $code
        ": difference-callback ( -- alien )"
        "    int { int int } cdecl [ - ] alien-callback ;"
    }
}
{ $errors "Throws an " { $link callsite-not-compiled } " if the word calling " { $link alien-callback } " is not compiled." } ;

HELP: alien-assembly
{ $values { "args..." "zero or more objects passed to the C function" } { "return" "a C return type" } { "parameters" "a sequence of C parameter types" } { "abi" "one of " { $link cdecl } " or " { $link stdcall } } { "quot" quotation } { "return..." "the return value of the function, if not " { $link void } } }
{ $description
    "Invokes arbitrary machine code, generated at compile-time by the quotation. Input parameters are taken from the data stack, and the return value is pushed on the data stack after the function returns. A return type of " { $link void } " indicates that no value is to be expected."
    $nl
    "The quotation passed to this word must preserve the " { $link ds-reg } " and " { $link rs-reg } " registers. Note that this is not a " { $snippet "call" } " in the assembly sense, so there is no return address on the stack."
    $nl
    "It's important to mind the ABI. For instance, on x86.32, parameters are passed on the stack in " { $snippet "ESP" } ", while on x86.64 arguments are passed in " { $snippet "RDI" } ", " { $snippet "RSI" } ", " { $snippet "RDX" } ", and " { $snippet "RCX" } ", and then on the stack. On Windows 64, integers and pointers are passed in " { $snippet "RCX" } ", " { $snippet "RDX" } ", " { $snippet "R8" } ", and " { $snippet "R9" } "."
    $nl
    "There are Factor words for the input parameters, such as " { $snippet "param-reg-0" } " and " { $snippet "param-reg-1" } "."
    $nl
    "For output parameters, use " { $link return-reg } "."
    $nl
}
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $errors "Throws an " { $link callsite-not-compiled } " if the word calling " { $link alien-assembly } " is not compiled." } ;

{ alien-invoke alien-indirect alien-assembly alien-callback } related-words

ARTICLE: "alien-expiry" "Alien expiry"
"When an image is loaded, any alien objects which persisted from the previous session are marked as having expired. This is because the C pointers they contain are almost certainly no longer valid."
$nl
"For this reason, the " { $link POSTPONE: ALIEN: } " word should not be used in source files, since loading the source file then saving the image will result in the literal becoming expired. Use " { $link <alien> } " instead, and ensure the word calling " { $link <alien> } " is not declared " { $link POSTPONE: flushable } "."
{ $subsections expired? } ;

ARTICLE: "aliens" "Alien addresses"
"Instances of the " { $link alien } " class represent pointers to C data outside the Factor heap:"
{ $subsections
    <alien>
    <displaced-alien>
    alien-address
}
"Anywhere that an " { $link alien } " instance is accepted, the " { $link f } " singleton may be passed in to denote a null pointer."
$nl
"Usually alien objects do not have to be created and dereferenced directly; instead declaring C function parameters and return values as having a " { $link pointer } " type such as " { $snippet "void*" } " takes care of the details."
{ $subsections
    "syntax-aliens"
    "alien-expiry"
}
"When higher-level abstractions won't do:"
{ $subsections "reading-writing-memory" }
{ $see-also "c-data" "c-types-specs" } ;

ARTICLE: "reading-writing-memory" "Reading and writing memory directly"
"Numerical values can be read from memory addresses and converted to Factor objects using the various typed memory accessor words:"
{ $subsections
    alien-signed-1
    alien-unsigned-1
    alien-signed-2
    alien-unsigned-2
    alien-signed-4
    alien-unsigned-4
    alien-signed-cell
    alien-unsigned-cell
    alien-signed-8
    alien-unsigned-8
    alien-float
    alien-double
}
"Factor numbers can also be converted to C values and stored to memory:"
{ $subsections
    set-alien-signed-1
    set-alien-unsigned-1
    set-alien-signed-2
    set-alien-unsigned-2
    set-alien-signed-4
    set-alien-unsigned-4
    set-alien-signed-cell
    set-alien-unsigned-cell
    set-alien-signed-8
    set-alien-unsigned-8
    set-alien-float
    set-alien-double
} ;

ARTICLE: "alien-invoke" "Calling C from Factor"
"The easiest way to call into a C library is to define bindings using a pair of parsing words:"
{ $subsections
    POSTPONE: LIBRARY:
    POSTPONE: FUNCTION:
    POSTPONE: FUNCTION-ALIAS:
}
"The above parsing words create word definitions which call a lower-level word; you can use it directly, too:"
{ $subsections alien-invoke }
"Sometimes it is necessary to invoke a C function pointer, rather than a named C function:"
{ $subsections alien-indirect }
"There are some details concerning the conversion of Factor objects to C values, and vice versa. See " { $link "c-data" } "." ;

ARTICLE: "alien-callback" "Calling Factor from C"
"Callbacks can be defined and passed to C code as function pointers; the C code can then invoke the callback and run Factor code:"
{ $subsections
    alien-callback
    POSTPONE: CALLBACK:
}
"There are some caveats concerning the conversion of Factor objects to C values, and vice versa. See " { $link "c-data" } "."
{ $see-also "byte-arrays-gc" } ;

ARTICLE: "alien-globals" "Accessing C global variables"
"The " { $vocab-link "alien.syntax" } " vocabulary defines two parsing words for accessing the value of a global variable, and get the address of a global variable, respectively."
{ $subsections
    POSTPONE: C-GLOBAL:
    POSTPONE: &:
} ;

ARTICLE: "alien-assembly" "Calling arbitrary assembly code"
"It is possible to write a word whose body consists of arbitrary assembly code. The assembly receives parameters and returns values as per the platform's ABI; marshalling and unmarshalling Factor values is taken care of by the C library interface, as with " { $link alien-invoke } "."
$nl
"Assembler opcodes are defined in CPU-specific vocabularies:"
{ $list
    { $vocab-link "cpu.arm.assembler" }
    { $vocab-link "cpu.ppc.assembler" }
    { $vocab-link "cpu.x86.assembler" }
}
"The combinator for generating arbitrary assembly by calling a quotation at compile time:"
{ $subsection alien-assembly } ;

ARTICLE: "dll.private" "DLL handles"
"DLL handles are a built-in class of objects which represent loaded native libraries. DLL handles are instances of the " { $link dll } " class, and have a literal syntax used for debugging printouts; see " { $link "syntax-aliens" } "."
$nl
"Usually one never has to deal with DLL handles directly; the C library interface creates them as required. However if direct access to these operating system facilities is required, the following primitives can be used:"
{ $subsections
    dlopen
    dlsym
    dlclose
    dll-valid?
} ;

ARTICLE: "embedding-api" "Factor embedding API"
"The Factor embedding API is defined in " { $snippet "vm/master.h" } "."
$nl
"The " { $snippet "F_CHAR" } " type is an alias for the character type used for path names by the operating system; " { $snippet "char" } " on Unix and " { $snippet "wchar_t" } " on Windows."
$nl
"Including this header file into a C compilation unit will declare the following functions:"
{ $table
    { {
        { $code "void init_factor_from_args("
            "    F_CHAR *image, int argc, F_CHAR **argv, bool embedded"
            ")" }
        "Initializes Factor."
        $nl
        "If " { $snippet "image" } " is " { $snippet "NULL" } ", Factor will load an image file whose name is obtained by suffixing the executable name with " { $snippet ".image" } "."
        $nl
        "The " { $snippet "argc" } " and " { $snippet "argv" } " parameters are interpreted just like normal command line arguments when running Factor stand-alone; see " { $link "command-line" } "."
        $nl
        "The " { $snippet "embedded" } " flag ensures that this function returns as soon as Factor has been initialized. Otherwise, Factor will start up normally."
    } }
    { {
        { $code "char *factor_eval_string(char *string)" }
        "Evaluates a piece of code in the embedded Factor instance by passing the string to " { $link eval>string } " and returning the result. The result must be explicitly freed by a call to " { $snippet "factor_eval_free" } "."
    } }
    { {
        { $code "void factor_eval_free(char *result)" }
        "Frees a string returned by " { $snippet "factor_eval_string()" } "."
    } }
    { {
        { $code "void factor_yield(void)" }
        "Gives all Factor threads a chance to run."
    } }
    { {
        { $code "void factor_sleep(long us)" }
        "Gives all Factor threads a chance to run for " { $snippet "us" } " microseconds."
    } }
} ;

ARTICLE: "embedding-restrictions" "Embedding API restrictions"
"The Factor VM is not thread safe, and does not support multiple instances. There must only be one Factor instance per process, and this instance must be consistently accessed from the same thread for its entire lifetime. Once initialized, a Factor instance cannot be destroyed other than by exiting the process." ;

ARTICLE: "embedding-factor" "What embedding looks like from Factor"
"Factor code will run inside an embedded instance in the same way it would run in a stand-alone instance."
$nl
"One exception is that the global " { $link input-stream } " and " { $link output-stream } " streams are not bound by default, to avoid conflicting with any I/O the host process might perform. The " { $link init-stdio } " words must be called explicitly to initialize terminal streams."
$nl
"There is a word which can detect when Factor is embedded:"
{ $subsections embedded? }
"No special support is provided for calling out from Factor into the owner process. The C library interface works fine for this task - see " { $link "alien" } "." ;

ARTICLE: "embedding" "Embedding Factor into C applications"
"The Factor " { $snippet "Makefile" } " builds the Factor VM both as an executable and a library. The library can be used by other applications. File names for the library on various operating systems:"
{ $table
    { { $strong "OS" } { $strong "Library name" } { $strong "Shared?" } }
    { "Windows XP/Vista" { $snippet "factor.dll" } "Yes" }
    { "Mac OS X" { $snippet "libfactor.dylib" } "Yes" }
    { "Other Unix" { $snippet "libfactor.a" } "No" }
}
"An image file must be supplied; a minimal image can be built, however the compiler must be included for the embedding API to work (see " { $link "bootstrap-cli-args" } ")."
{ $subsections
    "embedding-api"
    "embedding-factor"
    "embedding-restrictions"
} ;

ARTICLE: "alien" "C library interface"
"Factor can directly call C functions in native libraries. It is also possible to compile callbacks which run Factor code, and pass them to native libraries as function pointers."
$nl
"The C library interface is entirely self-contained; there is no C code which one must write in order to wrap a library."
$nl
"C library interface words are found in the " { $vocab-link "alien" } " vocabulary and its subvocabularies."
{ $warning "C does not perform runtime type checking, automatic memory management or array bounds checks. Incorrect usage of C library functions can lead to crashes, data corruption, and security exploits." }
{ $subsections
    "loading-libs"
    "alien-invoke"
    "alien-callback"
    "c-data"
    "classes.struct"
    "alien-globals"
    "alien-assembly"
    "dll.private"
    "embedding"
} ;

ABOUT: "alien"
