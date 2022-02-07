USING: accessors kernel gamedev.game_lib colors.constants ui.gadgets gamedev.board sequences combinators ;

IN: gamedev.game_test

: init_board ( -- board )
    3 3 f make-board ;

! :: grid ()

:: fry ( loc -- quot )
    [ "vocab:gamedev/game_lib_test/resources/X.png" loc { 20 20 } draw-image ] ; inline

:: draw ( gadget -- gadget )
    ! init_board first2 :> ( w h )
    COLOR: pink set-background-color ! defaults to white if not set
    COLOR: green { 0 0 } { 150 150 } draw-filled-rectangle ! draws this first
    COLOR: blue { 0 0 } { 100 100 } draw-filled-rectangle
    ! "vocab:gamedev/game_lib_test/resources/X.png" { 20 40 } { 20 20 } draw-image
    ! "vocab:gamedev/game_lib_test/resources/O.png" { 60 40 } { 20 20 } draw-image
    { { 20 40 } { 60 40 } } [ fry ] map

    ! [ 0 w ] [ 0 h ] -> [{}]
    
    ! ['[ "vocab:gamedev/game_lib_test/resources/X.png" _ { 20 20 } draw-image ]] map

    ;



: display-window ( -- )
    { 200 200 } init-window ! initialize the window with dimensions
    draw ! optional function to draw rectangles or sprites
    display ; ! call display to see the window

    ! note: using relayout seems to change the window correctly

MAIN: display-window