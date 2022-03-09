USING: game.loop sequences math kernel accessors delegate io prettyprint namespaces ;

IN: gamedev.game_loop_test

! test game loop with a simple incrementor

TUPLE: test-class counter ;

SYMBOL: my-game-loop 

: change-counter ( test-class quot -- test-class )
    swap dup counter>> rot call dup . >>counter ; inline

: tick-update ( test-class -- test-class )
    dup counter>> 5 = 
    [ stop-game ] 
    [ [ 1 + ] change-counter ] if ;

: draw-update ( tick-slice delegate -- )
    drop drop ;

M: test-class tick* tick-update drop ;

M: test-class draw* draw-update ;

: stop-game ( -- )
    my-game-loop get stop-loop ;

: new-test-class ( -- test-class )
    0 test-class boa ;

: new-game-loop ( interval test-class -- game-loop )
    <game-loop> dup my-game-loop set ;

: create-loop ( -- )
    1000000000 new-test-class new-game-loop start-loop ;


MAIN: create-loop