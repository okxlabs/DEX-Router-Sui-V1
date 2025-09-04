module turbos_clmm::swap_router {
    use sui::tx_context::{Self, TxContext};
    use turbos_clmm::pool::{Self, Pool, Versioned};
    use sui::coin::{Self, Coin};
    use sui::clock::{Self, Clock};

    const MAX_SQRT_PRICE_X64: u128 = 79226673515401279992447579055;
    const MIN_SQRT_PRICE_X64: u128 = 4295048016;

    public fun swap_a_b_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
        coins_a: vector<Coin<CoinTypeA>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeB>, Coin<CoinTypeA>) {
        abort 0
    }

    public fun swap_b_a_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
        coins_b: vector<Coin<CoinTypeB>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        abort 0
    }
}