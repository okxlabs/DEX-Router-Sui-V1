module 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::market {
    struct Market has store, key {
        id: 0x2::object::UID,
        borrow_dynamics: 0x779b5c547976899f5474f3a5bc0db36ddf4697ad7e5a901db0415c2281d28162::wit_table::WitTable<0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::borrow_dynamics::BorrowDynamics, 0x1::type_name::TypeName, 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::borrow_dynamics::BorrowDynamic>,
        collateral_stats: 0x779b5c547976899f5474f3a5bc0db36ddf4697ad7e5a901db0415c2281d28162::wit_table::WitTable<0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::collateral_stats::CollateralStats, 0x1::type_name::TypeName, 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::collateral_stats::CollateralStat>,
        interest_models: 0x779b5c547976899f5474f3a5bc0db36ddf4697ad7e5a901db0415c2281d28162::ac_table::AcTable<0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::interest_model::InterestModels, 0x1::type_name::TypeName, 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::interest_model::InterestModel>,
        risk_models: 0x779b5c547976899f5474f3a5bc0db36ddf4697ad7e5a901db0415c2281d28162::ac_table::AcTable<0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::risk_model::RiskModels, 0x1::type_name::TypeName, 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::risk_model::RiskModel>,
        limiters: 0x779b5c547976899f5474f3a5bc0db36ddf4697ad7e5a901db0415c2281d28162::wit_table::WitTable<0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::limiter::Limiters, 0x1::type_name::TypeName, 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::limiter::Limiter>,
        reward_factors: 0x779b5c547976899f5474f3a5bc0db36ddf4697ad7e5a901db0415c2281d28162::wit_table::WitTable<0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::incentive_rewards::RewardFactors, 0x1::type_name::TypeName, 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::incentive_rewards::RewardFactor>,
        asset_active_states: 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::asset_active_state::AssetActiveStates,
        vault: 0xefe8b36d5b2e43728cc323298626b83177803521d195cfb11e15b910e892fddf::reserve::Reserve,
    }

    // decompiled from Move bytecode v6
}

