module oracles::oracle_decimal {
    public struct OracleDecimal has copy, drop, store {
        base: u128,
        expo: u64,
        is_expo_negative: bool,
    }
}
