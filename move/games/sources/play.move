module games::play {
    use games::flag::{Self, Flag};
    use games::gcoin::{Self, GCOIN};
    use games::record::{Self, Record};
    use games::random::{randint};

    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::sui::SUI;
    use sui::tx_context::{TxContext, sender};
    use sui::transfer::{Self, transfer};
    use sui::balance;
    use sui::object;
    use std::string::String;
    use sui::event;
    use sui::object::ID;

    struct Returned has copy, drop{
        coin_id: ID,
        record_id: ID
    }

    struct Score has copy, drop{
        score: u64
    }

    const ErrCoin_Exist: u64 = 1003;
    const ErrNot_Enough_Coin: u64 = 1004;
    const GAMEADDR :address = @0x7497bdeec1916b3fd1e8660290e98c3cf671d607;

    public entry fun init_coin(flag: &mut Flag,
                               player: String,
                               ctx: &mut TxContext){
        assert!(!flag::exists_coin<GCOIN>(flag, player), ErrCoin_Exist);
        let zero_coin = coin::zero<GCOIN>(ctx);
        let coin_id = object::id(&zero_coin);
        transfer(zero_coin, sender(ctx));
        flag::add<GCOIN>(flag, coin_id, player);
        let record_id = record::create(ctx);
        event::emit(Returned{coin_id, record_id})
    }

    public entry fun increase_score(record: &mut Record, value: u64){
        record::increase_score(record, value);
    }

    public entry fun decrease_score(record: &mut Record, value: u64){
        record::decrease_score(record, value);
    }

    public entry fun buy_coin(coin: &mut Coin<GCOIN>,
                              payment: &mut Coin<SUI>,
                              amount: u64,
                              cap: &mut TreasuryCap<GCOIN>,
                              ctx: &mut TxContext) {
        assert!(coin::value(payment) >= amount, ErrNot_Enough_Coin);
        let coin_balance = coin::balance_mut(payment);
        let paid_coin = balance::split(coin_balance, amount);
        transfer::transfer(coin::from_balance<SUI>(paid_coin, ctx), GAMEADDR);
        coin::join(coin, coin::mint(cap, amount, ctx));
    }

    public entry fun shoot(
        coin: &mut Coin<GCOIN>,
        cap: &mut TreasuryCap<GCOIN>,
        value: u64,
        record: &mut Record,
        ctx: &mut TxContext){
        gcoin::pay_coin(coin, cap, value, ctx);
        let result = randint(value>>2, ctx);
        gcoin::join_coin(coin, cap, result, ctx);
        record::increase_score(record, result);
        event::emit(Score{score:result})
    }

    public entry fun gain_coin(
        coin: &mut Coin<GCOIN>,
        cap: &mut TreasuryCap<GCOIN>,
        value: u64,
        ctx: &mut TxContext){
        gcoin::join_coin(coin, cap, value, ctx);
    }
}