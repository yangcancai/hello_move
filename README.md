# hello_move
# hello_move
## Install
* 1. `cd ~/` [Download startcoin-macos-latest](https://github.com/starcoinorg/starcoin/releases/download/v1.10.1/starcoin-macos-latest), then `unzip starcoin-macos-latest.zip`
* 2. `git clone https://github.com/diem/move.git`
* 3. `cd move && ./scripts/dev_setup.sh -yp`
* 4. Append below to ~/.zshrc 
      ```shell
      export DOTNET_ROOT="/Users/you/.dotnet"
      export PATH="/Users/you/.dotnet/tools:$PATH"
      export PATH="/Users/you/starcoin-artifacts:$PATH"
      export Z3_EXE="/Users/you/bin/z3"
      export CVC5_EXE="/Users/you/bin/cvc5"
      export BOOGIE_EXE="/Users/you/.dotnet/tools/boogie" 
      export alias move="mpm"
      ```
* 5. `source ~/.zshrc`
* 6. Enjoy!

## Test,Build,Prove

```shell
hello_move/BasicCoin$ move package test --dev
CACHED MoveStdlib
BUILDING BasicCoin
Running Move unit tests
[ PASS    ] 0x2::BasicCoinTest::test_balance_before_publish
[ PASS    ] 0x2::MyOddCoin::setup_and_mint_success_test
[ PASS    ] 0x2::MyOddCoin::transfer_success_test
[ PASS    ] 0x2::BasicCoinTest::test_balance_of
[ PASS    ] 0x2::BasicCoinTest::test_mint
[ PASS    ] 0x2::BasicCoinTest::test_mint_before_publish
[ PASS    ] 0x2::BasicCoinTest::test_mint_not_moudle_owner
[ PASS    ] 0x2::BasicCoinTest::test_publish_balance
[ PASS    ] 0x2::BasicCoinTest::test_publish_twice_fail
[ PASS    ] 0x2::BasicCoinTest::test_transfer
[ PASS    ] 0x2::BasicCoinTest::test_transfer_balance_not_enough
[ PASS    ] 0x2::BasicCoinTest::test_transfer_before_from_publish
[ PASS    ] 0x2::BasicCoinTest::test_transfer_before_publish
[ PASS    ] 0x2::BasicCoinTest::test_transfer_before_to_publish
Test result: OK. Total tests: 14; passed: 14; failed: 0
 hello_move/BasicCoin$ move package build -d
BUILDING MoveStdlib
BUILDING BasicCoin
 hello_move/BasicCoin$ move package prove
[INFO] preparing module 0x2::BasicCoin
[INFO] preparing module 0x2::MyOddCoin
[INFO] transforming bytecode
[INFO] generating verification conditions
[INFO] 9 verification conditions
[INFO] running solver
[INFO] 0.041s build, 0.015s trafo, 0.018s gen, 1.149s verify, total 1.224s
```