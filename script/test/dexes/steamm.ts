// ============================================================================
// DEX Router STEAMM Test Script
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
const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

const USDC_ID = config["USDC_ID"]!;
const USDC_DECIMAL = 6;
const USDC_TYPE = `${USDC_ID}::coin::COIN`;

const WAL_TYPE = "0x356a26eb9e012a68958082340d4c4116e7f55615cf27affcff209cf0ae544f59::wal::WAL";
const WAL_DECIMAL = 9;

const STEAMM_BANK_USDC = "0x9e709157b2228dee4d71f24e91345e2b690beadce84a5a2312fb17b13ce40d58";
const STEAMM_LENDING_MARKET = "0x84030d26d85eaa7035084a057f2f11f701b7e2e4eda87551becbc7c97505ece1";
const STEAMM_CLOCK = "0x0000000000000000000000000000000000000000000000000000000000000006";
const STEAMM_BWALBUSDC_POOL = "0xe4455aac45acee48f8b69c671c245363faa7380b3dcbe3af0fbe00cc4b68e9eb";
const STEAMM_BANK_WAL = "0x8a7aaf08c6052f11fc2bfef961596aeb168bc61f27728762246c47f07e85677d";

const MAIN_POOL_TYPE = "0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::suilend::MAIN_POOL";
const USDC_COIN_TYPE = "0xdba34672e30cb065b1f93e3ab55318768fd6fef66c15942c9f7cb846e2f900e7::usdc::USDC";
const B_WAL_TYPE = "0x3005b2a01ace4673f8af040e53a6c012e4838543973ff9a3ac5e71b252103e8a::b_wal::B_WAL";
const B_USDC_TYPE = "0x7fb074a648b8521f65136ac701e94abf55151efc26a39cdab589fabe92285535::b_usdc::B_USDC";
const STEAMM_LP_BWAL_BUSDC_TYPE = "0x23f259afed1123d56602c98a51689b0a6ef46fcb57189fced25501be00c77dea::steamm_lp_bwal_busdc::STEAMM_LP_BWAL_BUSDC";

// ============================================================================
// OMMV2 Specific Constants (Commented)
// ============================================================================

const STEAMM_BSUI_BUSDC_POOL = "0x05eaddda2390e8de1ba930393f0927e4528cecddbf235844df0212ed6088bac1";
const STEAMM_BANK_SUI = "0xbe2e72e8fce74746d1e91e5c71e1a0cbf7acfdf60871a41834acf78759fc2bcc";
const STEAMM_PYTH_FEED = "0x919bba48fddc65e9885433e36ec24278cc80b56bf865f46e9352fa2852d701bc";
const STEAMM_PYTH_PRICE_ID_0 = "0x801dbc2f0053d34734814b2d6df491ce7807a725fe9a01ad74a07e9c51396c37";
const STEAMM_PYTH_PRICE_ID_1 = "0x5dec622733a204ca27f5a90d8c2fad453cc6665186fd5dff13a83d0b6c9027ab";
const STEAMM_PYTH_CONTRACT = "0xe84b649199654d18c38e727212f5d8dacfc3cf78d60d0a7fc85fd589f280eb2b";
const B_SUI_TYPE = "0x1f6c075e031d3e380bfdacb09b44e8df76566e44f332025bafb6e2249bc9d5ec::b_sui::B_SUI";
const STEAMM_LP_BSUI_BUSDC_TYPE = "0xa08fe8189c4580e9c83fac65ecf56b8dedcdb4c5144424733a9d82254820a327::steamm_lp_bsui_busdc::STEAMM_LP_BSUI_BUSDC";

// ============================================================================
// Main STEAMM Test Function
// ============================================================================

async function main(): Promise<void> {
    // Initialize provider and wallet
    const provider = new SuiClient({
        url: "https://sui-rpc.publicnode.com"
    });

    const keypair = Ed25519Keypair.fromSecretKey(PRIVATE_KEY);
    const walletAddress = keypair.getPublicKey().toSuiAddress();

    console.log("Wallet Address:", walletAddress);

    // Test price identifier functionality
    const objectId = await readPriceIdentifierFromTable("0x234c9ffca44613ab87a2711325b6e17bad9ece0449b917c8bd9c0ad7a0506cc2", "0x2b89b9dc8fdf9f34709a5b106b472f0f39bb6ca9ce04b0fd7f2e971688e2e53b");
    if (objectId) {
        console.log(`Success! Object ID: ${objectId}`);
    } else {
        console.log("Object not found");
    }

    // Create transaction block
    const txb = new TransactionBlock();

    // Transaction parameters
    const gasBudget = 150000000;
    const swapAmount = 0.01 * 10 ** 6; // 0.01 USDC in micro units

    txb.setGasBudget(gasBudget);

    const bankUsdc = txb.object(STEAMM_BANK_USDC);
    const lendingMarket = txb.object(STEAMM_LENDING_MARKET);
    const clock = txb.object(STEAMM_CLOCK);


    // ============================================================================
    // STEAMM CPMM Swap: USDC → WAL
    // ============================================================================

    // Get USDC coins from wallet
    const usdcCoins = await provider.getCoins({
        owner: walletAddress,
        coinType: USDC_COIN_TYPE
    });

    if (usdcCoins.data.length === 0) {
        throw new Error("No USDC coins found in wallet");
    }

    // Merge USDC coins if multiple
    const coins = usdcCoins.data;
    const [primaryCoin, ...mergeCoins] = coins.filter((coin) => coin.coinType === USDC_COIN_TYPE);
    let primaryCoinIn = txb.object(primaryCoin.coinObjectId);

    if (mergeCoins.length > 0) {
        txb.mergeCoins(
            primaryCoinIn,
            mergeCoins.map((coin) => txb.object(coin.coinObjectId)),
        );
    }

    // Split the required amount
    const [inputCoin] = txb.splitCoins(primaryCoinIn, [txb.pure(swapAmount.toString())]);

    const bwalbusdcPool = txb.object(STEAMM_BWALBUSDC_POOL);
    const bankWAL = txb.object(STEAMM_BANK_WAL);

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::steamm_cpmm_swap_b2a_with_return`,
        arguments: [
            bwalbusdcPool,
            bankWAL,
            bankUsdc,
            lendingMarket,
            inputCoin, // Use dynamic coin instead of hardcoded
            txb.pure(swapAmount.toString()),
            txb.pure(0),
            clock,
        ],
        typeArguments: [
            MAIN_POOL_TYPE,
            WAL_TYPE,
            USDC_COIN_TYPE,
            B_WAL_TYPE,
            B_USDC_TYPE,
            STEAMM_LP_BWAL_BUSDC_TYPE,
        ],
    });

    // ============================================================================
    // Finalize Transaction
    // ============================================================================

    // Set transaction sender
    txb.setSender(walletAddress);

    txb.moveCall({
        target: `${DEX_ROUTER}::router::finalize`,
        arguments: [
            outputCoin,
            txb.pure(1),
            txb.pure(0),
            txb.pure(walletAddress),
            txb.pure(walletAddress),
            txb.pure(0),
            txb.pure(WAL_DECIMAL),
        ],
        typeArguments: [
            WAL_TYPE
        ]
    });

    // ============================================================================
    // OMMV2 Swap Example (Commented - for reference only)
    // ============================================================================

    /*
    // STEAMM OMMV2 Swap: USDC → SUI
    // This example demonstrates how to use STEAMM's OMMV2 (Order Matching Market Version 2)
    // which uses Pyth price feeds for more advanced trading

    const bsuiBusdcPool = txb.object(STEAMM_BSUI_BUSDC_POOL);
    const bankSui = txb.object(STEAMM_BANK_SUI);

    // Get Pyth price feeds for price discovery
    const price0 = txb.moveCall({
        target: `${STEAMM_PYTH_CONTRACT}::oracles::get_pyth_price`,
        arguments: [
            txb.object(STEAMM_PYTH_FEED),
            txb.object(STEAMM_PYTH_PRICE_ID_0),
            txb.pure(0),
            clock,
        ],
        typeArguments: [],
    });

    const price1 = txb.moveCall({
        target: `${STEAMM_PYTH_CONTRACT}::oracles::get_pyth_price`,
        arguments: [
            txb.object(STEAMM_PYTH_FEED),
            txb.object(STEAMM_PYTH_PRICE_ID_1),
            txb.pure(1),
            clock,
        ],
        typeArguments: [],
    });

    // Get USDC coins from wallet (same as above)
    // ... coin merging logic ...

    const [ommv2OutputCoin, ommv2OutputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::steamm_ommv2_swap_b2a_with_return`,
        arguments: [
            bsuiBusdcPool,
            bankSui,
            bankUsdc,
            lendingMarket,
            price0,
            price1,
            inputCoin,
            txb.pure(swapAmount.toString()),
            txb.pure(0),
            clock,
        ],
        typeArguments: [
            MAIN_POOL_TYPE,
            SUI_TYPE,
            USDC_COIN_TYPE,
            B_SUI_TYPE,
            B_USDC_TYPE,
            STEAMM_LP_BSUI_BUSDC_TYPE,
        ],
    });

    // Finalize OMMV2 transaction
    txb.moveCall({
        target: `${DEX_ROUTER}::router::finalize`,
        arguments: [
            ommv2OutputCoin,
            txb.pure(1),
            txb.pure(0),
            txb.pure(walletAddress),
            txb.pure(walletAddress),
            txb.pure(0),
            txb.pure(SUI_DECIMAL),
        ],
        typeArguments: [SUI_TYPE]
    });
    */

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const result = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx
    });

    console.log("STEAMM Swap Result:", result);
}

/**
 * Read price_identifier data from specified Table
 * @param tableId The object ID of the Table
 * @param priceIdentifier The price_identifier to query
 * @returns Returns the found object ID, or null if not found
 */
async function readPriceIdentifierFromTable(
    tableId: string,
    priceIdentifier: string
): Promise<string | null> {
    try {
        // Create provider using new API
        const provider = new SuiClient({
            url: "https://sui-rpc.publicnode.com"
        });

        console.log(`Starting Table query: ${tableId}`);
        console.log(`Querying price_identifier: ${priceIdentifier}`);

        // Process priceIdentifier, ensure 0x prefix is removed
        const cleanIdentifier = priceIdentifier.startsWith('0x') ? priceIdentifier.slice(2) : priceIdentifier;

        // Convert price_identifier to bytes array
        const bytes = Array.from(Buffer.from(cleanIdentifier, 'hex'));

        // Build query parameters - using bytes field instead of name field
        const dynamicField = {
            type: "0x8d97f1cd6ac663735be08d1d2b6d02a159e711586461306ce60a2b7a6a565a9e::price_identifier::PriceIdentifier",
            value: {
                bytes: bytes
            }
        };

        console.log("Query parameters:", JSON.stringify(dynamicField, null, 2));

        // Query dynamic field in Table
        const result = await provider.getDynamicFieldObject({
            parentId: tableId,
            name: dynamicField
        });
        console.log("Query result:", result);

                // Check query result
        if (result.data &&
            result.data.content &&
            "fields" in result.data.content) {

            const fields = result.data.content.fields as any;

            // Extract object ID - handle different possible field names
            const objectId = fields.value || fields.id || fields.objectId;

            if (objectId) {
                console.log(`Found corresponding object ID: ${objectId}`);
                return objectId;
            } else {
                console.log("Object ID field not found");
                return null;
            }
        } else {
            console.log("No matching data found");
            return null;
        }

    } catch (error) {
        console.error("Error querying Table:", error);
        throw error;
    }
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing STEAMM test:", error);
    process.exit(1);
});

