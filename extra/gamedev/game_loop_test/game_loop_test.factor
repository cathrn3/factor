USING: game.loop sequences math kernel accessors delegate ;

IN: gamedev.game_loop_test

! test game loop with a simple incrementor

TUPLE: test-class counter ;



: tick-update ( test-class -- n )
    counter>> 1 + ;

: draw-update ( n -- n ) ;

M: test-class tick* tick-update ;

M: test-class draw* draw-update ;





: new-test-class ( -- test-class )
    0 test-class boa ;

: new-game-loop ( interval test-class -- game-loop )
    <game-loop> ;

: create-loop ( -- game-loop )
    1000 new-test-class new-game-loop ;

MAIN: create-loop