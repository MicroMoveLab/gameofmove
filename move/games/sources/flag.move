module games::flag {
    use std::ascii::into_bytes;
    use std::string::{Self, String};
    use std::type_name::{get, into_string};

    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::{TxContext};

    friend games::play;

    struct Flag has key {
        id: UID,
        coin: Table<String, ID>
    }
    fun init(ctx: &mut TxContext) {
        let coin = table::new<String, ID>(ctx);
        let flag = Flag {
            id: object::new(ctx),
            coin,
        };
        transfer::share_object(flag);
    }

    public(friend) fun add<Coin>(flag: &mut Flag, id: ID, player: String) {
        table::add(&mut flag.coin, get_name<Coin>(player), id);
    }

    public(friend) fun exists_coin<Coin>(flag: &mut Flag, player: String): bool {
        table::contains(&flag.coin, get_name<Coin>(player))
    }

    public fun get_name<Coin>(player: String): String {
        let name = get<Coin>();
        let str = player;
        string::append_utf8(&mut str, b"-");
        string::append_utf8(&mut str, into_bytes(into_string(name)));
        str
    }
}