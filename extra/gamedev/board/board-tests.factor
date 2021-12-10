! Copyright (C) 2021 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test gamedev.board kernel ;
IN: gamedev.board.tests

TUPLE: test array ;

! make-cells unit tests
{ { { 0 0 } { 0 0 } } } [ 0 2 2 make-cells ] unit-test

{ { } } [ f 0 0 make-cells ] unit-test

! make-board tests
{ T{ board f 0 0 { } f } } [ 0 0 f make-board ] unit-test

{ T{ board f 4 4 
    { { t t t t }
      { t t t t }
      { t t t t }
      { t t t t } }
    t } }
[ 4 4 t make-board ] unit-test

! get-cell tests
{ t } [ 2 2 t make-board { 0 1 } get-cell ] unit-test

! set-cell tests
{ T{ board f 1 1 { { t } } f } }
[ 1 1 f make-board t { 0 0 } set-cell ] unit-test

{ T{ board f 1 2 
    { { T{ test f { 0 } } }
      { f } }
      T{ test f { 0 } } } }
[ 1 2 { 0 } test boa make-board f { 0 1 } set-cell ] unit-test

! delete-cell tests
{ T{ board f 1 1 { { f } } f } }
[ T{ board f 1 1 { { t } } f } { 0 0 } delete-cell ] unit-test

{ T{ board f 2 2
    { { t f }
      { t t } }
      f } }
[ T{ board f 2 2 
    { { t t }
      { t t } }
      f } { 1 0 } delete-cell ] unit-test

! duplicate-cell tests
{ T{ board f 2 2
    { { f f }
      { t t } }
      f } }
[ 2 2 f make-board t { 0 1 } set-cell { 0 1 } { 1 1 } duplicate-cell ] unit-test

! move-cell tests
{ T{ board f 2 1 { { 3 0 } } 3 } }
[ T{ board f 2 1 { { 0 1 } } 3 } { 0 0 } { 1 0 } move-cell ] unit-test

