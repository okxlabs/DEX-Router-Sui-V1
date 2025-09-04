module mmt_v3::trade {
    use sui::balance::{Balance};
    use sui::clock::{Clock};
    use mmt_v3::pool::{Pool};
    use mmt_v3::version::{Version};

    // FlashLoanEvent flash_swap & loan receipt hot potatoes.
    public struct FlashSwapReceipt {
        pool_id: ID,
        amount_x_debt: u64,
        amount_y_debt: u64,
    }

    public fun flash_swap<X, Y>(
        pool: &mut Pool<X, Y>,
        is_x_to_y: bool,
        exact_input: bool,
        amount_specified: u64,
        sqrt_price_limit: u128,
        clock: &Clock,
        version: &Version,        
        ctx: &TxContext
    ) : (Balance<X>, Balance<Y>, FlashSwapReceipt) {
        abort 0
    }

    public fun swap_receipt_debts(
        receipt: &FlashSwapReceipt,
    ): (u64, u64) {
        abort 0
    }

    public fun repay_flash_swap<X, Y>(
        pool: &mut Pool<X, Y>,
        receipt: FlashSwapReceipt,
        balance_x: Balance<X>,
        balance_y: Balance<Y>,
        version: &Version,        
        ctx: &TxContext,
    ) {
        abort 0
    }
}