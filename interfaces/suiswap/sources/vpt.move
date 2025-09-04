module suiswap::vpt {

    struct ValuePerToken has copy, drop, store {
        sum: u256,
        amount: u256
    }

}