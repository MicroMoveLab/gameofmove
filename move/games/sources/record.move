module games::record {

    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext, sender};

    const ErrOverflow: u64 = 1001;
    const ErrNotEnough: u64 = 1002;

    struct Record has key, store {
        id: UID,
        begin_score: u64,
        score: u64
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            Record {
                id: object::new(ctx),
                begin_score: 0,
                score: 0
            },
            sender(ctx)
        )
    }

    public fun create(ctx: &mut TxContext): ID {
        let record = Record {
            id: object::new(ctx),
            begin_score: 0,
            score: 0
        };
        let record_id = object::id(&record);
        transfer::transfer(
            record,
            sender(ctx)
        );
        record_id
    }

    public fun increase_score(self: &mut Record, value: u64) {
        self.score = self.score + value;
    }

    spec increase_score{
        ensures self.score == old(self.score) + value;
    }

    public fun decrease_score(self: &mut Record, value: u64) {
        assert!(self.score < value, ErrNotEnough);
        self.score = self.score - value;
    }

    spec decrease_score {
        aborts_if self.score < value with ErrNotEnough;
        ensures self.score == old(self.score) - value;
    }

    public fun increate_begin_score(self: &mut Record, value: u64) {
        self.begin_score = self.begin_score + value;
    }

    spec increate_begin_score{
        ensures self.begin_score == old(self.begin_score) + value;
    }



}