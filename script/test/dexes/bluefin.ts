// ============================================================================
// DEX Router Bluefin Test Script
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
const DEX_ROUTER = config["DEX_EXTENDED"]!;

// Token configurations
const AUSD_DECIMAL = 6;
const AUSD_TYPE = '0x2053d08c1e2bd02791056171aab0fd12bd7cd7efad2ab8f6b9c8902f14df2ff2::ausd::AUSD';

const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

// ============================================================================
// Bluefin Specific Constants
// ============================================================================

const BF_CLOCK = "0x0000000000000000000000000000000000000000000000000000000000000006";
const BF_MARKET = "0x03db251ba509a8d5d8777b6338836082335d93eecbdd09a11e190a1cff51c352";
const BF_VAULT = "0xb30df44907da6e9f3c531563f19e6f4a203d70f26f8a33ad57881cd7781e592d";

// CLMM sqrt_price_limit boundaries (no restriction)
const MIN_SQRT_PRICE = BigInt("4295048017");                    // For a2b direction
const MAX_SQRT_PRICE = BigInt("79226673515401279992447579050"); // For b2a direction

// ============================================================================
// Main Bluefin Test Function
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

    // Transaction parameters
    const gasBudget = 150000000;
    const swapAmount = 100000000; // Adjust amount as needed

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const inputCoin = txb.splitCoins(
        txb.gas,
        [txb.pure(swapAmount.toString())]
    );

    // ============================================================================
    // Bluefin Swap: SUI → AUSD
    // ============================================================================

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::bluefin_spot_swap_a2b_with_return`,
        arguments: [
            txb.object(BF_CLOCK),                        // clock
            txb.object(BF_MARKET),                       // market
            txb.object(BF_VAULT),                        // vault
            inputCoin,                                   // coin_in
            txb.pure(true),                              // by_amount_in
            txb.pure(swapAmount),                        // amount
            txb.pure(0),                                 // amount_threshold
            txb.pure(MIN_SQRT_PRICE, "u128"),            // sqrt_price_limit (no limit for b2a)
            txb.pure(0),                                 // order_id
            txb.pure(AUSD_DECIMAL),                      // decimal
        ],
        typeArguments: [SUI_TYPE, AUSD_TYPE]
    });

    // ============================================================================
    // Finalize Transaction
    // ============================================================================

    // Set transaction sender
    txb.setSender(walletAddress);

    txb.moveCall({
        target: `${DEX_ROUTER}::router::finalize`,
        arguments: [
            outputCoin,                    // input_coin
            txb.pure(0),                   // min_amount
            txb.pure(0),                   // commission_rate
            txb.pure(walletAddress),       // referral_address
            txb.pure(walletAddress),       // receiver_address
            txb.pure(0),                   // order_id
            txb.pure(AUSD_DECIMAL),         // decimal
        ],
        typeArguments: [AUSD_TYPE]
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

    console.log("Bluefin Swap Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing Bluefin test:", error);
    process.exit(1);
});