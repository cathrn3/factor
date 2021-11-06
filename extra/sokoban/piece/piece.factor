! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math math.vectors sequences
sokoban.tetromino lists.lazy namespaces colors colors.constants 
math.ranges random ;
IN: sokoban.piece

! The level_num is an index into the tetromino's states array,
! and the position is added to the tetromino's blocks to give
! them their location on the sokoban board. If the location is f
! then the piece is not yet on the board.

TUPLE: piece
    { tetromino tetromino }
    { level_num integer initial: 0 }
    { location array initial: { 0 0 } } ;

: <piece> ( tetromino -- piece )
    piece new swap >>tetromino ;

: (piece-blocks) ( piece -- blocks )
    ! rotates the piece
    [ level_num>> ] [ tetromino>> states>> ] bi nth ;

: wall-blocks ( piece -- blocks )
    [ (piece-blocks) ] [ location>> ] bi [ v+ ] curry map ;

: piece-blocks ( piece -- blocks )
    location>> { } 1sequence ; ! literally just returns the location in a sequence

: set-player-location ( piece board-width -- piece )
    drop 0 startinglocs get first nth >>location ;

: set-box-location ( piece level -- piece )
    ! sets the location of the boxes to where they are defined in tetromino
    over tetromino>> states>> nth first >>location ; 

: reset-box-location ( piece -- piece )
    ! resets box location using startinglocs symbol
    dup tetromino>> dup states>> 0 swap remove-nth startinglocs get second prefix >>states >>tetromino ; 

: is-goal? ( goal-piece location move -- ? )
    ! check if next move is a goal or not
    v+ swap tetromino>> states>> first member? ;

: <board-piece> ( -- piece )
    get-board <piece> ;

: <player-piece> ( board-width -- piece )
    get-player <piece> swap set-player-location ;

:: <box-piece> ( n goal-piece level  -- piece )
    n get-box <piece> level set-box-location dup [ tetromino>> ] [ location>> ] bi
    goal-piece swap { 0 0 } is-goal?
    [
        COLOR: blue
    ]
    [
        COLOR: orange
    ] if
    >>color drop ;

: <goal-piece> ( board-width -- piece )
    ! TODO: rotate goal according to level, right now it is only using the goals of the first level
    drop get-goal <piece> ;

: <player-llist> ( board-width -- llist )
    [ [ <player-piece> ] curry ] keep [ <player-llist> ] curry lazy-cons ;

:: <box-seq> ( goal-piece bw level -- seq )
    ! get list of boxes on corresponding level
    level get-num-boxes [0,b] [ goal-piece level <box-piece> ] map ;

: (rotate-piece) ( level_num inc n-states -- level_num' )
    [ + ] dip rem ;

: rotate-piece ( piece inc -- piece )
    over tetromino>> states>> length
    [ (rotate-piece) ] 2curry change-level_num ;

: move-piece ( piece move -- piece )
    [ v+ ] curry change-location ;
