// ============================================================================
// DEX Router DeepBook Test Script
// ============================================================================
// Tests: deepbook_swap_quote_to_base_with_return (Quote -> Base, SUI -> DEEP)
// Pool: DEEP/SUI (Base=DEEP, Quote=SUI). Input SUI from gas, output DEEP.
// ============================================================================

import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { SuiClient } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui.js/utils";
import * as dotenv from "dotenv";

// Load environment variables
dotenv.config();

// ============================================================================
// Configuration Constants
// ============================================================================

// Environment validation
const PRIVATE_KEY_STR = process.env.PRIVATE_KEY_STR;
if (!PRIVATE_KEY_STR) {
    throw new Error("PRIVATE_KEY_STR environment variable is required");
}

// Private key processing
const PRIVATE_KEY = Buffer.from(PRIVATE_KEY_STR, "base64").subarray(1);

// Load configuration
const config = require("../../config/configInfo.json");
const DEX_ROUTER = config["DEX"]!;

// Token configurations
const USDC_ID = config["USDC_ID"]!;
const USDC_DECIMAL = 6;
const USDC_TYPE = `${USDC_ID}::coin::COIN`;

const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

// DEEP token (hardcoded)
const DEEP_TYPE = "0xdeeb7a4662eec9f2f3def03fb937a663dddaa2e215b8078a284d026b7946c270::deep::DEEP";
const DEEP_DECIMAL = 9;

// ============================================================================
// DeepBook Specific Constants
// ============================================================================
// DEEP/SUI pool (BaseAsset=DEEP, QuoteAsset=SUI)
const DEEPBOOK_POOL = "0xb663828d6217467c8a1838a03793da896cbe745b150ebd57d82f814ca579fc22";

// ============================================================================
// Main DeepBook Test Function
// ============================================================================

async function main(): Promise<void> {
    // Initialize provider and wallet
    const provider = new SuiClient({
        url: "https://sui-rpc.publicnode.com"
    });

    const keypair = Ed25519Keypair.fromSecretKey(PRIVATE_KEY);
    const walletAddress = keypair.getPublicKey().toSuiAddress();

    console.log("Wallet Address:", walletAddress);

    // Create transaction block
    const txb = new TransactionBlock();

    // Transaction parameters: SUI in -> DEEP out
    const gasBudget = 40511200;
    const swapAmount = 1 * 10 ** SUI_DECIMAL; // 1 SUI (quote_in)
    const minBaseOut = 0; // minimum DEEP out (base)

    txb.setGasBudget(gasBudget);

    // Prepare quote asset coin (SUI) — split from gas
    const quoteInCoin = txb.splitCoins(
        txb.gas,
        [txb.pure(swapAmount.toString())]
    );

    // ============================================================================
    // DeepBook Swap: Quote -> Base (SUI -> DEEP)
    // deepbook_swap_quote_to_base_with_return(pool, quote_in, min_base_out, clock, ctx)
    // ============================================================================

    const [baseReturn, baseOutValue] = txb.moveCall({
        target: `${DEX_ROUTER}::router::deepbook_swap_quote_to_base_with_return`,
        arguments: [
            txb.object(DEEPBOOK_POOL),   // self: &mut Pool<BaseAsset, QuoteAsset>
            quoteInCoin,                  // quote_in: Coin<SUI>
            txb.pure(minBaseOut),         // min_base_out: u64
            txb.object(SUI_CLOCK_OBJECT_ID), // clock: &Clock
        ],
        typeArguments: [DEEP_TYPE, SUI_TYPE] // BaseAsset=DEEP, QuoteAsset=SUI
    });

    // ============================================================================
    // Finalize Transaction (base out = DEEP)
    // ============================================================================

    txb.setSender(walletAddress);

    txb.moveCall({
        target: `${DEX_ROUTER}::router::finalize`,
        arguments: [
            baseReturn,                  // input_coin (base = DEEP out from swap)
            txb.pure(0),                 // min_amount
            txb.pure(0),                 // commission_rate
            txb.pure(walletAddress),     // referral_address
            txb.pure(walletAddress),     // receiver_address
            txb.pure(0),                 // order_id
            txb.pure(DEEP_DECIMAL),      // decimal (base = DEEP)
        ],
        typeArguments: [DEEP_TYPE]
    });

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const result = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx
    });

    // Uncomment to execute transaction
    // const executeResult = await provider.signAndExecuteTransactionBlock({
    //     transactionBlock: builtTx,
    //     signer: keypair,
    //     options: {
    //         showObjectChanges: true,
    //         showEvents: true,
    //         showBalanceChanges: true
    //     }
    // });

    console.log("DeepBook Swap (quote->base, SUI->DEEP) Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing DeepBook test:", error);
    process.exit(1);
});
