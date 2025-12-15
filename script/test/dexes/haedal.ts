// ============================================================================
// DEX Router Haedal Test Script
// ============================================================================

import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { SuiClient } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
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
const SUI_TYPE = "0x2::sui::SUI";
const SUI_DECIMAL = 9;

const HASUI_TYPE = "0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI";
const HASUI_DECIMAL = 9;

// ============================================================================
// Haedal Specific Constants
// ============================================================================

const SUI_SYSTEM_STATE = "0x0000000000000000000000000000000000000000000000000000000000000005";
const HAEDAL_STAKING = "0x47b224762220393057ebf4f70501b6e657c3e56684737568439a04f80849b2ca";

// Validator address (use 0x0 for default validator selection)
const VALIDATOR_ADDRESS = "0x0000000000000000000000000000000000000000000000000000000000000000";

// ============================================================================
// Main Haedal Test Function
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
    const swapAmount = 1 * 10 ** 9; // 1 SUI in mist

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const amountCoin = txb.splitCoins(txb.gas, [txb.pure(swapAmount.toString())]);

    // ============================================================================
    // Haedal Swap: SUI → haSUI
    // ============================================================================

    const suiSystemState = txb.object(SUI_SYSTEM_STATE);
    const haedalStaking = txb.object(HAEDAL_STAKING);

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::haedal_swap_a2b_with_return`,
        arguments: [
            suiSystemState,                              // sui_system_state
            haedalStaking,                               // staking
            amountCoin,                                  // coin_in
            txb.pure(VALIDATOR_ADDRESS, "address"),      // validater_address
        ],
        typeArguments: []
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
            txb.pure(1),                   // min_amount
            txb.pure(0),                   // commission_rate
            txb.pure(walletAddress),       // referral_address
            txb.pure(walletAddress),       // receiver_address
            txb.pure(0),                   // order_id
            txb.pure(HASUI_DECIMAL),       // decimal
        ],
        typeArguments: [HASUI_TYPE]
    });

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const dryRunResult = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx
    });

    console.log("Dry Run Result:", dryRunResult);

    // Check if dry run was successful
    if (dryRunResult.effects.status.status !== "success") {
        console.error("Dry run failed:", dryRunResult.effects.status);
        return;
    }

    console.log("\n✅ Dry run successful! Executing real transaction...\n");

    // Execute real transaction
    const realResult = await provider.signAndExecuteTransactionBlock({
        transactionBlock: txb,
        signer: keypair,
        options: {
            showEffects: true,
            showEvents: true,
            showBalanceChanges: true,
        }
    });

    console.log("Transaction Digest:", realResult.digest);
    console.log("Transaction Status:", realResult.effects?.status);
    console.log("Balance Changes:", realResult.balanceChanges);
    console.log("\n🎉 Haedal Swap executed successfully!");
    console.log(`View on explorer: https://suiscan.xyz/mainnet/tx/${realResult.digest}`);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing Haedal test:", error);
    process.exit(1);
});

