module 0xad013d5fde39e15eabda32b3dbdafd67dac32b798ce63237c27a8f73339b9b6f::u128 {
    public fun checked_mul(arg0: u128, arg1: u128) : u128 {
        assert!(is_safe_mul(arg0, arg1), 1003);
        arg0 * arg1
    }

    public fun is_safe_mul(arg0: u128, arg1: u128) : bool {
        340282366920938463463374607431768211455 / arg0 >= arg1
    }

    public fun mul_div(arg0: u128, arg1: u128, arg2: u128) : u128 {
        abort 0
    }

    // decompiled from Move bytecode v6
}
