! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple continuations kernel sequences
slots.private vocabs vocabs.parser ;
IN: fixups

CONSTANT: vocab-renames {
    { "math.intervals" { "intervals" "0.99" } }
    { "math.ranges" { "ranges" "0.99" } }
}

CONSTANT: word-renames {
    { "32bit?" { "layouts:32-bit?" "0.99" } }
    { "64bit?" { "layouts:64-bit?" "0.99" } }
    { "lines" { "io:read-lines" "0.99" } }
    { "words" { "splitting:split-words" "0.99" } }
    { "contents" { "io:read-contents" "0.99" } }
    { "exists?" { "io.files:file-exists?" "0.99" } }
    { "string-lines" { "splitting:split-lines" "0.99" } }
    { "[-inf,a)" { "math.intervals:[-inf,b)" "0.99" } }
    { "[-inf,a]" { "math.intervals:[-inf,b]" "0.99" } }
    { "(a,b)" { "ranges:(a..b)" "0.99" } }
    { "(a,b]" { "ranges:(a..b]" "0.99" } }
    { "[a,b)" { "ranges:[a..b)" "0.99" } }
    { "[a,b]" { "ranges:[a..b]" "0.99" } }
    { "[0,b)" { "ranges:[0..b)" "0.99" } }
    { "[0,b]" { "ranges:[0..b]" "0.99" } }
    { "[1,b)" { "ranges:[1..b)" "0.99" } }
    { "[1,b]" { "ranges:[1..b]" "0.99" } }
    { "assoc-combine" { "assocs:assoc-union-all" "0.99" } }
    { "assoc-refine" { "assocs:assoc-intersect-all" "0.99" } }
    { "assoc-merge" { "assocs.extras:assoc-collect" "0.99" } }
    { "assoc-merge!" { "assocs.extras:assoc-collect!" "0.99" } }
    { "peek-from" { "modern.html:peek1-from" "0.99" } }
    { "in?" { "interval-sets:interval-in?" "0.99" } }
    { "substitute" { "regexp.classes:(substitute)" "0.99" } }
    { "combine" { "sets:union-all" "0.99" } }
    { "refine" { "sets:intersect-all" "0.99" } }
    { "read-json-objects" { "json.reader:read-json" "0.99" } }
    { "init-namespaces" { "namespaces:init-namestack" "0.99" } }
    { "iota" { "sequences:<iota>" ".98" } }
}

: compute-assoc-fixups ( continuation name assoc -- seq )
    swap '[ drop _ = ] assoc-filter [
        drop { }
    ] [
        swap '[
            first2 dupd first2
            " in Factor " glue " renamed to " glue "Fixup: " prepend
            swap drop no-op-restart
            _ <restart>
        ] map
    ] if-empty ;

GENERIC: compute-fixups ( continuation error -- seq )

M: object compute-fixups
    "error" over ?offset-of-slot
    [ slot compute-fixups ] [ 2drop { } ] if* ;

M: f compute-fixups 2drop { } ;

M: no-vocab compute-fixups
    [ name>> vocab-renames compute-assoc-fixups ] [ drop { } ] if* ;

M: no-word-error compute-fixups
    [ name>> word-renames compute-assoc-fixups ] [ drop { } ] if* ;
