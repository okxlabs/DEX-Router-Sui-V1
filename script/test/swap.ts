// ============================================================================
// DEX Router Swap Test Script
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
const config = require("../config/configInfo.json");
const DEX_ROUTER = config["DEX"]!;

// Token configurations
const USDC_ID = config["USDC_ID"]!;
const USDC_DECIMAL = 6;
const USDC_TYPE = `${USDC_ID}::coin::COIN`;

const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

// Contract addresses
const GLOBAL_CONFIG = "0xdaa46292632c3c4d8f31f23ea0f9b36a28ff3677e9684980e4438403a67a3d8f";
const POOL = "0xcf994611fd4c48e277ce3ffd4d4364c914af2c3cbb05f7bf6facd371de688630";

// ============================================================================
// Swap Transaction Function
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

    // Swap parameters
    const swapAmount = 10000;
    const gasBudget = 4051120;

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const amountCoin = txb.splitCoins(
        txb.gas,
        [txb.pure(swapAmount.toString())]
    );

    // Execute swap
    const [outputCoin] = txb.moveCall({
        target: `${DEX_ROUTER}::router::cetus_swap_b2a_with_return`,
        arguments: [
            txb.object(GLOBAL_CONFIG),
            txb.object(POOL),
            txb.makeMoveVec({ objects: [amountCoin] }),
            txb.pure(true),                    // is_exact_in
            txb.pure(swapAmount),              // amount
            txb.pure(0),                       // min_amount_out
            txb.pure(BigInt("79226673515401279992447579055")), // sqrt_price_limit
            txb.object(SUI_CLOCK_OBJECT_ID),
            txb.pure(0),                       // fee_rate
            txb.pure(USDC_DECIMAL),            // decimals
        ],
        typeArguments: [USDC_TYPE, SUI_TYPE]
    });

    // Finalize transaction
    txb.moveCall({
        target: `${DEX_ROUTER}::router::finalize`,
        arguments: [
            outputCoin,                        // input_coin
            txb.pure(1),                       // min_amount
            txb.pure(0),                       // commission_rate
            txb.pure(walletAddress),           // referral_address
            txb.pure(walletAddress),           // receiver_address
            txb.pure(0),                       // order_id
            txb.pure(USDC_DECIMAL),             // decimal
        ],
        typeArguments: [USDC_TYPE]
    });

    // Set transaction sender
    txb.setSender(walletAddress);

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const result = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx,
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

    console.log("Transaction Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing swap:", error);
    process.exit(1);
});