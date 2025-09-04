/// Module: meta_vault
module meta_vault::vault{
    use sui::object::{Self, UID, ID};
    use sui::balance::Supply;
    use sui::coin::Coin;
    use sui::tx_context::TxContext;
    use meta_vault::version::{Version};
    use sui::object_bag::{Self, ObjectBag};

    struct Vault<phantom MetaCoin> has key {
        id: UID,

        /// The `Vault`'s `Supply` to allow minting and burning of `Balance<MetaCoin>`.
        supply: Supply<MetaCoin>,
        /// The `decimal` value of the `Vault`'s corresponding `Coin<MetaCoin>`.
        meta_coin_decimals: u8,
        /// The `ID` of the only active `VaultAssistantCap`.
        active_assistant_cap: ID,

        /// Maintains a mapping of `TypeName` -> `Metadata` for all `Coin` types underlying the
        /// `Vault`; i.e., for which `add_support_for_new_coin` has been called.
        metadata: ObjectBag,
        /// Sum of all `Metadata` priorities. This value is only updated during one of:
        ///  - `add_support_for_new_coin` / `add_support_for_new_coin_unsafe`.
        ///  - `set_priority`.
        total_priorities: u64,

        /// Holds all of the `Vault`'s idle liquidity through a `TypeName` -> `Coin<CoinType>` mapping.
        funds: ObjectBag,
        /// Holds all collected fees through a `TypeName` -> `Coin<CoinType>` mapping.
        fees: ObjectBag,
    }

    //************************************************************************************************//
    // DepositCap                                                                                     //
    //************************************************************************************************//

    /// Grants the holder the ability to deposit coins *into* a `Vault`; i.e., a `DepositCap` must
    ///  be acquired before the holder can call `deposit` or `swap`.
    struct DepositCap<phantom MetaCoin, phantom CoinIn> /* has hot_potato */ {
        /// The current exchange rate of `Coin<MetaCoin>` to `Coin<CoinIn>`. This exchange rate
        /// must be acquired from a trusted source (e.g., an oracle or on-chain-derived exchange
        /// rate).
        exchange_rate_meta_coin_to_coin_in: u128,
    }

    //************************************************************************************************//
    // WithdrawCap                                                                                    //
    //************************************************************************************************//

    /// Grants the holder the ability to withdraw coins *from* the `Vault`; i.e., a `WithdrawCap` must
    /// be aquired before the holder can call `withdraw` or `swap`.
    struct WithdrawCap<phantom MetaCoin, phantom CoinOut> /* has hot_potato */ {
        /// The current exchange rate of `Coin<MetaCoin>` to `Coin<CoinOut>`. This exchange rate
        /// rate must be acquired from a trusted source (e.g., an oracle or on-chain-derived exchange
        /// rate).
        exchange_rate_meta_coin_to_coin_out: u128,
    }

    /// Deposits an input coin (`Coin<CoinIn>`) into the `Vault` and mints an equivalent worth
    /// of `Coin<MetaCoin>`.
    ///
    /// A `DepositCap` must first be obtained from the `CoinIn`'s `whitelisted_app_id`. This
    /// `DepositCap` holds the exchange rate between `Coin<CoinIn>` -> `Coin<CoinMeta>`.
    ///
    /// The `Vault`'s `deposit_cap` field associated with the `CoinIn` type restricts the
    /// total `Balance<CoinIn>` it can hold.
    ///
    /// Aborts:
    ///   i. [meta_vault::version::EInvalidVersion]
    ///  ii. [meta_vault::vault::EZeroValue]
    /// iii. [meta_vault::vault::ECoinIsNotSupported]
    ///  iv. [meta_vault::vault::ENotEnoughSpaceToHandleDeposit]
    public fun deposit<MetaCoin, CoinIn>(
        vault: &mut Vault<MetaCoin>,
        version: &Version,
        deposit_cap: DepositCap<MetaCoin, CoinIn>,
        coin_in: Coin<CoinIn>,
        min_amount_out: u64,
        ctx: &mut TxContext,
    ): Coin<MetaCoin> {
        abort 0
    }

    /// Burns the input `Coin<MetaCoin>` and withdraws an equivalent worth of `Coin<CoinOut>` from
    /// the `Vault`.
    ///
    /// A `WithdrawCap` must first be obtained from the `CoinOut`'s `whitelisted_app_id`. This
    /// `WithdrawCap` holds the exchange rate between `Coin<CoinMetaCoin>` -> `Coin<CoinOut>`.
    ///
    /// Aborts:
    ///   i. [meta_vault::version::EInvalidVersion]
    ///  ii. [meta_vault::vault::ENotEnoughLiquidityToHandleWithdraw]
    public fun withdraw<MetaCoin, CoinOut>(
        vault: &mut Vault<MetaCoin>,
        version: &Version,
        withdraw_cap: WithdrawCap<MetaCoin, CoinOut>,
        meta_coin: Coin<MetaCoin>,
        min_amount_out: u64,
        ctx: &mut TxContext,
    ): Coin<CoinOut> {
        abort 0
    }
}