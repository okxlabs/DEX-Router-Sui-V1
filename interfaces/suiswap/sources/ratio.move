module suiswap::ratio {
    struct Ratio has copy, drop, store {
        num: u64,
        den: u64
    }
}