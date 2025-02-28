! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences splitting ;
IN: strings.tables

<PRIVATE

: format-row ( seq -- seq )
    dup longest length '[ _ "" pad-tail ] map! ;

: format-column ( seq -- seq )
    dup longest length '[ _ CHAR: \s pad-tail ] map! ;

PRIVATE>

: format-table ( table -- seq )
    [ [ split-lines ] map format-row flip ] map concat flip
    [ { } ] [
        [ but-last-slice [ format-column ] map! drop ] keep
        flip [ join-words ] map!
    ] if-empty ;
