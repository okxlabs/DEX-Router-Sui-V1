/// Module: version
module meta_vault::version{
    use sui::object::{Self, UID};

    /// The package's singleton object that contains all relevant configuration variables. This object
    ///  is used for versioning across the entire `MetaVault` package.
    struct Version has key {
        id: UID,
        /// Versioning field to allow for safe upgrades.
        version: u64,
    }
}