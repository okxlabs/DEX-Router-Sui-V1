module oracles::oracles {
    use sui::clock::Clock;
    use sui::bag::Bag;
    use sui::object::{ID, UID};
    use oracles::version::Version;
    use oracles::oracle_decimal::OracleDecimal;
    use pyth::price_feed::PriceFeed;
    use pyth::price_identifier::PriceIdentifier;
    use switchboard::aggregator::CurrentResult;

    public struct OracleRegistry has key, store {
        id: UID,
        config: OracleRegistryConfig,
        oracles: vector<Oracle>,
        version: Version,
        extra_fields: Bag
    }

    public struct OracleRegistryConfig has store {
        pyth_max_staleness_threshold_s: u64,
        pyth_max_confidence_interval_pct: u64,

        switchboard_max_staleness_threshold_s: u64,
        switchboard_max_confidence_interval_pct: u64,

        extra_fields: Bag
    }

    public struct Oracle has store {
        oracle_type: OracleType,
        extra_fields: Bag
    }

    public enum OracleType has store, drop, copy {
        Pyth {
            price_identifier: PriceIdentifier,
        },
        Switchboard {
            feed_id: ID,
        }
    }

    // hot potato ensures that price is fresh
    public struct OraclePriceUpdate has drop {
        oracle_registry_id: ID,
        oracle_index: u64,
        price: OracleDecimal,
        ema_price: Option<OracleDecimal>,
        metadata: OracleMetadata,
    }

    public enum OracleMetadata has store, drop, copy {
        Pyth {
            price_feed: PriceFeed,
        },
        Switchboard {
            current_result: CurrentResult,
        }
    }
}
