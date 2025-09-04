module alphafin_liquid_staking::liquid_staking {
    use 0x3::sui_system::{SuiSystemState};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::tx_context::{Self, TxContext};

    struct LiquidStakingInfo<phantom P> has key, store {}

    // User operations
    public fun mint<P: drop>(
        self: &mut LiquidStakingInfo<P>, 
        system_state: &mut SuiSystemState, 
        sui: Coin<SUI>, 
        ctx: &mut TxContext
    ): Coin<P> {
        abort 0
    }

    public fun redeem<P: drop>(
        self: &mut LiquidStakingInfo<P>,
        lst: Coin<P>,
        system_state: &mut SuiSystemState, 
        ctx: &mut TxContext
    ): Coin<SUI> {
        abort 0
    }
}