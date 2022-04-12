module My::MyOddCoin{
    use Std::Signer;
    use My::BasicCoin;
    use Std::Errors;
    struct MyOddCoin has drop{}
    const ENOT_ODD: u64 = 0;
    const MODULE_OWNER: address = @My;
    public fun setup_and_mint(module_owner: &signer, account: &signer, amount: u64){
        let addr = Signer::address_of(account);
        BasicCoin::publish_balance<MyOddCoin>(account);
        BasicCoin::mint<MyOddCoin>(module_owner, addr, amount);
    }
    public fun transfer(from: &signer, to: address, amount: u64){
        assert!(amount % 2 == 1, Errors::invalid_argument(ENOT_ODD));
        BasicCoin::transfer<MyOddCoin>(from ,to, amount);
    }
    public fun balance_of(account: address): u64{
        BasicCoin::balance_of<MyOddCoin>(account)
    }
    #[test(account=@0xab, owner=@My)]
    fun setup_and_mint_success_test(owner: &signer, account: &signer){
        setup_and_mint(owner,account, 10);
        assert!(balance_of(Signer::address_of(account)) == 10, 0);
    }
    #[test(from=@0xab, to=@0xbc, owner=@My)]
    fun transfer_success_test(owner: &signer, from: &signer, to: &signer){
        setup_and_mint(owner, from, 100);
        setup_and_mint(owner, to, 0);
        transfer(from, Signer::address_of(to), 99);
        let balance_from = balance_of(Signer::address_of(from));
        let balance_to = balance_of(Signer::address_of(to));
        assert!(balance_from == 1, 0);
        assert!(balance_to == 99, 0);
    }
}