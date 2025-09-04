module suiswap::sbalance {
    use sui::balance::{Balance};

    struct SBalance<phantom Ty0> has store {
        balance: Balance<Ty0>,
        supply: u64
    }
}