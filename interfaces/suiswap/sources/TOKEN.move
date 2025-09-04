module suiswap::TOKEN {
    use sui::object::{ID, UID};

    use suiswap::sbalance::{SBalance};
    use sui::balance::{Balance};

    use suiswap::ratio::Ratio;

    struct TOKEN has drop {
        dummy_field: bool
    }

    struct TokenBank has key {
        id: UID,
        owner: address,
        balance: SBalance<TOKEN>,
        admin_balance: Balance<TOKEN>,
        early_unlock_fee: Ratio,
        stats_liquidity_mine_amount: u64,
        token_farm_ids: vector<ID>,
        token_ido_ids: vector<ID>,
        token_airdrop_ids: vector<ID>
    }
}