module 0xb0575765166030556a6eafd3b1b970eba8183ff748860680245b9edd41c716e7::storage {
    struct Storage has store {
        sui_pool: 0x2::balance::Balance<0x2::sui::SUI>,
        validator_infos: vector<ValidatorInfo>,
        total_sui_supply: u64,
        last_refresh_epoch: u64,
        extra_fields: 0x2::bag::Bag,
    }
    
    struct ValidatorInfo has store {
        staking_pool_id: 0x2::object::ID,
        validator_address: address,
        active_stake: 0x1::option::Option<0x3::staking_pool::FungibleStakedSui>,
        inactive_stake: 0x1::option::Option<0x3::staking_pool::StakedSui>,
        exchange_rate: 0x3::staking_pool::PoolTokenExchangeRate,
        total_sui_amount: u64,
        extra_fields: 0x2::bag::Bag,
    }
    
    // decompiled from Move bytecode v6
}

