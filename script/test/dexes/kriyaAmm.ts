// ============================================================================
// DEX Router KriyaAMM Test Script
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

const USDT_ID = config["USDT_ID"]!;
const USDT_DECIMAL = 6;
const USDT_TYPE = `${USDT_ID}::coin::COIN`;

// ============================================================================
// Kriya AMM Specific Constants
// ============================================================================

const KRIYA_AMM_STABLE_POOL = "0xd0086b7713e0487bbf5bb4a1e30a000794e570590a6041155cdbebee3cb1cb77"; // USDC-USDT
const KRIYA_AMM_CPMM_POOL = "0x5af4976b871fa1813362f352fa4cada3883a96191bb7212db1bd5d13685ae305"; // USDC-SUI

// ============================================================================
// Main KriyaAMM Test Function
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
    const swapAmount = 36767; // USDT amount

    txb.setGasBudget(gasBudget);
        // ============================================================================
    // Kriya AMM Swap: USDT → USDC
    // ============================================================================

    // Get USDT coins from wallet
    const usdtCoins = await provider.getCoins({
        owner: walletAddress,
        coinType: USDT_TYPE
    });

    if (usdtCoins.data.length === 0) {
        throw new Error("No USDT coins found in wallet");
    }

    // Merge USDT coins if multiple
    const coins = usdtCoins.data;
    const [primaryCoin, ...mergeCoins] = coins.filter((coin) => coin.coinType === USDT_TYPE);
    let primaryCoinIn = txb.object(primaryCoin.coinObjectId);

    if (mergeCoins.length > 0) {
        txb.mergeCoins(
            primaryCoinIn,
            mergeCoins.map((coin) => txb.object(coin.coinObjectId)),
        );
    }

    // Split the required amount
    const [inputCoin] = txb.splitCoins(primaryCoinIn, [txb.pure(swapAmount)]);

    // Kriya AMM specific objects
    const stablePool = txb.object(KRIYA_AMM_STABLE_POOL);

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::kriya_amm_swap_token_y_with_return`,
        arguments: [
            stablePool,             // pool
            inputCoin,              // coin_in
            txb.pure(swapAmount),   // amount_in
            txb.pure(0),            // min_return
            txb.pure(0),            // order_id
            txb.pure(USDT_DECIMAL)  // decimal
        ],
        typeArguments: [USDC_TYPE, USDT_TYPE]
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
            txb.pure(USDC_DECIMAL),                   // decimal
        ],
        typeArguments: [USDC_TYPE]
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

    console.log("KriyaAMM Swap Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing KriyaAMM test:", error);
    process.exit(1);
});