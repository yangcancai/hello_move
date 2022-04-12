module My::BasicCoin{
    use Std::Signer;
    use Std::Errors;

    const MODULE_OWNER: address = @My;
    // error
    const EALREADY_HAS_BALANCE: u64 = 0;
    const ENOT_MODULE_OWNER: u64 = 1;
    const EINSUFFICIENT_BALANCE: u64 = 2;
    const ENOT_HAS_BALANCE: u64 = 3;
    struct Coin<phantom CoinType> has store{
        value: u64
    }
    struct Balance<phantom CoinType> has key{
        coin: Coin<CoinType>
    }
    public fun publish_balance<CoinType>(account: &signer){
        // check resource exists
        assert!(!exists<Balance<CoinType>>(Signer::address_of(account)),Errors::already_published(EALREADY_HAS_BALANCE));
        let balance = Balance<CoinType>{coin: Coin{value: 0}};
        // create 
        move_to(account, balance)
    }
    spec publish_balance{
        let addr = Signer::address_of(account);
        aborts_if exists<Balance<CoinType>>(addr);
    }
    public fun mint<CoinType>(module_owner: &signer, mint_addr: address, amount: u64) acquires Balance{
        assert!(exists<Balance<CoinType>>(mint_addr),Errors::not_published(ENOT_HAS_BALANCE));
        // check module_owner
        assert!(Signer::address_of(module_owner)==MODULE_OWNER,Errors::requires_address(ENOT_MODULE_OWNER));
        // modify resource
        let addr = borrow_global_mut<Balance<CoinType>>(mint_addr);
        addr.coin.value = amount;
    }
   spec mint{
       let owner_addr = Signer::address_of(module_owner);
       aborts_if owner_addr != MODULE_OWNER;
       aborts_if !exists<Balance<CoinType>>(mint_addr);
       aborts_if amount > MAX_U64;
   }
    // Read resource 
    public fun balance_of<CoinType>(owner: address):u64 acquires Balance{
        assert!(exists<Balance<CoinType>>(owner),Errors::not_published(ENOT_HAS_BALANCE));
        let addr = borrow_global<Balance<CoinType>>(owner);
        addr.coin.value
    }
    spec balance_of {
        pragma aborts_if_is_strict;
        aborts_if !exists<Balance<CoinType>>(owner);
    }
    public fun transfer<CoinType>(from: &signer, to: address, amount: u64) acquires Balance{
        assert!(exists<Balance<CoinType>>(to),Errors::not_published(ENOT_HAS_BALANCE));
        assert!(exists<Balance<CoinType>>(Signer::address_of(from)),Errors::not_published(ENOT_HAS_BALANCE));
        let from_addr = Signer::address_of(from);
        assert!(from_addr != to, 0);
        // withdraw
        let coin = withdraw<CoinType>(from_addr, amount);
        deposite<CoinType>(to, coin);
    }
    spec transfer{
        let from_addr = Signer::address_of(from);
        aborts_if !exists<Balance<CoinType>>(to);
        aborts_if !exists<Balance<CoinType>>(from_addr);
        aborts_if from_addr == to;
        let balance_from = global<Balance<CoinType>>(from_addr).coin.value;
        let balance_to = global<Balance<CoinType>>(to).coin.value;
        aborts_if balance_from < amount;
        aborts_if balance_to + amount > MAX_U64;
        let post balance_from_post = global<Balance<CoinType>>(from_addr).coin.value;
        let post balance_to_post = global<Balance<CoinType>>(to).coin.value;
        ensures balance_from_post == balance_from - amount;
        ensures balance_to_post == balance_to + amount;
    }
    fun withdraw<CoinType>(mint_addr: address, amount:u64): Coin<CoinType> acquires Balance{
        let balance = balance_of<CoinType>(mint_addr);
        assert!(balance >= amount, Errors::limit_exceeded(EINSUFFICIENT_BALANCE));
        let mint_addr = borrow_global_mut<Balance<CoinType>>(mint_addr);
        mint_addr.coin.value = balance - amount;
        Coin<CoinType>{value: amount}
    }
    spec withdraw{
        let balance = global<Balance<CoinType>>(mint_addr).coin.value;
        aborts_if !exists<Balance<CoinType>>(mint_addr);
        aborts_if balance < amount;
        // represents the balance of after the execution
        let post balance_post = global<Balance<CoinType>>(mint_addr).coin.value;
        ensures balance_post == balance - amount;
        ensures result == Coin<CoinType>{value: amount};
    }
    fun deposite<CoinType>(mint_addr: address, coin: Coin<CoinType>) acquires Balance{
        let Coin<CoinType>{value: value} = coin;
        let balance = balance_of<CoinType>(mint_addr);
        let mint_addr = borrow_global_mut<Balance<CoinType>>(mint_addr);
        mint_addr.coin.value = balance + value;
    }
    spec deposite{
        include DespositeSchema<CoinType>{addr: mint_addr, amount:coin.value};
       }
    spec schema DespositeSchema<CoinType>{
        addr: address; 
        amount: u64;
        aborts_if !exists<Balance<CoinType>>(addr);
        let balance = global<Balance<CoinType>>(addr).coin.value;
        let value = amount;
        aborts_if balance + value > MAX_U64;
        let post balance_post = global<Balance<CoinType>>(addr).coin.value;
        ensures balance_post == balance + value;
    }
   
}