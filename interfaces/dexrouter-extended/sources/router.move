module 0x2419dfa70719c1a3aaa2d948484bb95ba4e04ef04a1aef8c8e1b2329c40d3342::router {
    struct Versioned has store, key {
        id: 0x2::object::UID,
        version: u64,
        admin: address,
    }
    
    struct OrderRecord has copy, drop {
        order_id: u64,
        decimal: u8,
        out_amount: u64,
    }
    
    struct CommissionRecord has copy, drop {
        commission_amount: u64,
        referral_address: address,
    }
    
    struct HopRecord has copy, drop {
        out_amount: u64,
    }
    
    struct UpgradeEvent has copy, drop {
        old_version: u64,
        new_version: u64,
    }
    
    public entry fun change_admin(arg0: &mut Versioned, arg1: address, arg2: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg2) == arg0.admin, 8);
        arg0.admin = arg1;
    }
    
    public fun check_version(arg0: &Versioned) {
        assert!(arg0.version == 0, 9);
    }
    
    fun destroy_or_transfer<T0>(arg0: 0x2::coin::Coin<T0>, arg1: &0x2::tx_context::TxContext) {
        if (0x2::coin::value<T0>(&arg0) == 0) {
            0x2::coin::destroy_zero<T0>(arg0);
        } else {
            0x2::transfer::public_transfer<0x2::coin::Coin<T0>>(arg0, 0x2::tx_context::sender(arg1));
        };
    }
    
    fun init(arg0: &mut 0x2::tx_context::TxContext) {
        let v0 = Versioned{
            id      : 0x2::object::new(arg0), 
            version : 0, 
            admin   : 0x2::tx_context::sender(arg0),
        };
        0x2::transfer::share_object<Versioned>(v0);
    }

    
    public entry fun upgrade(arg0: &mut Versioned, arg1: &mut 0x2::tx_context::TxContext) {
        assert!(0x2::tx_context::sender(arg1) == arg0.admin, 8);
        let v0 = arg0.version;
        assert!(v0 < 0, 10);
        arg0.version = 0;
        let v1 = UpgradeEvent{
            old_version : v0, 
            new_version : 0,
        };
        0x2::event::emit<UpgradeEvent>(v1);
    }
    
    // decompiled from Move bytecode v6
}

