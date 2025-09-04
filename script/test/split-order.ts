// ============================================================================
// DEX Router Split Order Test Script
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
const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

// ============================================================================
// Split with Percentage Test Function
// ============================================================================

async function testSplitWithPercentage(): Promise<void> {
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
    const gasBudget = 4051120;
    const splitAmount = 10000000; // 10 SUI in mist
    const splitPercentage = 1000; // 10% (1000/10000)

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const inputCoin = txb.splitCoins(
        txb.gas,
        [txb.pure(splitAmount.toString())]
    );

    // Split with percentage call - 10% split
    const [splitCoin, splitCoinValue, leftCoin, leftCoinValue] = txb.moveCall({
        target: `${DEX_ROUTER}::router::split_with_percentage`,
        arguments: [
            inputCoin,                      // input coin
            txb.pure(splitPercentage)       // 10% split (1000/10000)
        ],
        typeArguments: [SUI_TYPE]
    });

    // Transfer coins
    txb.transferObjects([splitCoin], txb.pure(walletAddress));
    txb.transferObjects([leftCoin], txb.pure(walletAddress));
    txb.transferObjects([inputCoin], txb.pure(walletAddress));

    // Set transaction sender
    txb.setSender(walletAddress);

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

    console.log("Split with Percentage Result:", result);
}

// ============================================================================
// Split with Percentage for Commission Test Function
// ============================================================================

async function testSplitWithPercentageForCommission(): Promise<void> {
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
    const gasBudget = 4051120;
    const commissionAmount = 10000000; // 10 SUI in mist
    const commissionPercentage = 300; // 3% (300/10000)

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const inputCoin = txb.splitCoins(
        txb.gas,
        [txb.pure(commissionAmount.toString())]
    );

    // Split with percentage for commission call - 3% commission
    const [remainingCoin, remainingCoinValue] = txb.moveCall({
        target: `${DEX_ROUTER}::router::split_with_percentage_for_commission`,
        arguments: [
            inputCoin,                         // input coin
            txb.pure(commissionPercentage),    // 3% commission (300/10000)
            txb.pure(walletAddress)        // commission recipient
        ],
        typeArguments: [SUI_TYPE]
    });

    // Transfer remaining coins
    txb.transferObjects([remainingCoin], txb.pure(walletAddress));
    txb.transferObjects([inputCoin], txb.pure(walletAddress));

    // Set transaction sender
    txb.setSender(walletAddress);

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

    console.log("Split with Commission Result:", result);
}

// ============================================================================
// Main Execution Function
// ============================================================================

async function main(): Promise<void> {
    console.log("=== DEX Router Split Order Tests ===\n");

    try {
        // Test split with percentage (10% split)
        console.log("Testing split with percentage...");
        await testSplitWithPercentage();

        console.log("\n" + "=".repeat(50) + "\n");

        // Test split with percentage for commission (3% commission)
        console.log("Testing split with percentage for commission...");
        await testSplitWithPercentageForCommission();

        console.log("\n=== All tests completed successfully! ===");

    } catch (error) {
        console.error("Error during test execution:", error);
        process.exit(1);
    }
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
});