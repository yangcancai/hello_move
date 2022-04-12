#[test_only]    
module My::BasicCoinTest{
    use Std::Signer;
    use My::BasicCoin;
    struct MyTestCoin has drop{}
    #[test(account=@0xAB)]
    #[expected_failure]
    fun test_publish_twice_fail(account: &signer){
        BasicCoin::publish_balance<MyTestCoin>(account);
        BasicCoin::publish_balance<MyTestCoin>(account);
    }
    #[test(account=@0xAB)]
    fun test_publish_balance(account: &signer){
        BasicCoin::publish_balance<MyTestCoin>(account);
        let addr = Signer::address_of(account);
        assert!(BasicCoin::balance_of<MyTestCoin>(addr) == 0, 0);
    }
     #[test(account=@My, mint_addr=@0xAB)]
     #[expected_failure]
    fun test_mint_before_publish(account: &signer, mint_addr: &signer){
        let mint_addr = Signer::address_of(mint_addr);
        BasicCoin::mint<MyTestCoin>(account, mint_addr, 10);
    }
    #[test(account=@0xA, mint_addr=@0xAB)]
    #[expected_failure]
    fun test_mint_not_moudle_owner(account: &signer, mint_addr: &signer){
        BasicCoin::publish_balance<MyTestCoin>(mint_addr);
        let mint_addr = Signer::address_of(mint_addr);
        BasicCoin::mint<MyTestCoin>(account, mint_addr, 10);
    }
    #[test(account=@My, mint_addr=@0xAB)]
    fun test_mint(account: &signer, mint_addr: &signer) {
        BasicCoin::publish_balance<MyTestCoin>(mint_addr);
        let mint_addr = Signer::address_of(mint_addr);
        BasicCoin::mint<MyTestCoin>(account, mint_addr, 10);
        assert!(BasicCoin::balance_of<MyTestCoin>(mint_addr) == 10, 0);
    }
    #[test(account=@0xaa)]
    #[expected_failure]
    fun test_balance_before_publish(account: &signer) {
         let addr = Signer::address_of(account);
        let coin = BasicCoin::balance_of<MyTestCoin>(addr);
        assert!(coin==0, 0);

    }
    #[test(account=@0xAA)]
    fun test_balance_of(account: &signer){
        let addr = Signer::address_of(account);
        BasicCoin::publish_balance<MyTestCoin>(account);
        let coin = BasicCoin::balance_of<MyTestCoin>(addr);
        assert!(coin==0, 0);
    }
    #[test(from=@0xBB,to=@0xCC)]
    #[expected_failure]
    fun test_transfer_balance_not_enough(from: &signer, to: &signer){
        BasicCoin::publish_balance<MyTestCoin>(from);
        BasicCoin::publish_balance<MyTestCoin>(to);
        BasicCoin::transfer<MyTestCoin>(from,Signer::address_of(to),100);
    }
    #[test(from=@0xBB,to=@0xCC)]
    #[expected_failure]
    fun test_transfer_before_publish(from: &signer, to: &signer){
        BasicCoin::transfer<MyTestCoin>(from,Signer::address_of(to),100);
        assert!(BasicCoin::balance_of<MyTestCoin>(Signer::address_of(from))==0, 0);
        assert!(BasicCoin::balance_of<MyTestCoin>(Signer::address_of(to))==100, 0);

    }
    #[test(from=@0xBB,to=@0xCC)]
    #[expected_failure]
    fun test_transfer_before_to_publish(from: &signer, to: &signer){
        let from_addr = Signer::address_of(from);
        BasicCoin::publish_balance<MyTestCoin>(from);
        BasicCoin::transfer<MyTestCoin>(from,Signer::address_of(to),100);
        assert!(BasicCoin::balance_of<MyTestCoin>(from_addr)==0, 0);
        assert!(BasicCoin::balance_of<MyTestCoin>(Signer::address_of(to))==100, 0);

    }
    #[test(from=@0xBB,to=@0xCC)]
    #[expected_failure]
    fun test_transfer_before_from_publish(from: &signer, to: &signer) {
        let to_addr = Signer::address_of(to);
        let from_addr = Signer::address_of(from);
        BasicCoin::publish_balance<MyTestCoin>(to);
        BasicCoin::transfer<MyTestCoin>(from,Signer::address_of(to),100);
        assert!(BasicCoin::balance_of<MyTestCoin>(from_addr)==0, 0);
        assert!(BasicCoin::balance_of<MyTestCoin>(to_addr)==100, 0);
    }

    #[test(module_owner=@My, from=@0xBB,to=@0xCC)]
    fun test_transfer(module_owner:&signer, from: &signer, to: &signer) {
        BasicCoin::publish_balance<MyTestCoin>(from);
        BasicCoin::publish_balance<MyTestCoin>(to);
        BasicCoin::mint<MyTestCoin>(module_owner, Signer::address_of(from), 100);
        BasicCoin::transfer<MyTestCoin>(from,Signer::address_of(to),100);
        assert!(BasicCoin::balance_of<MyTestCoin>(Signer::address_of(from))==0, 0);
        assert!(BasicCoin::balance_of<MyTestCoin>(Signer::address_of(to))==100, 0);
    }
}