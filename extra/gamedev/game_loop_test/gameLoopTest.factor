! USING: game.loop ;

! IN: gamedev.gameLoopTest

! ! test game loop with a simple incrementor

! : newTestClass ( -- testClass )
!     0 testClass boa ;

! : newGameLoop ( interval testClass -- gameLoop )
!     <game-loop> ;

! : createLoop ( -- gameLoop )
!     1000 newTestClass newGameLoop ;

! MAIN: createLoop