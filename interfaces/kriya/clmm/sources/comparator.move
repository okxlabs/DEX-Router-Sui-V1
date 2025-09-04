module 0xf6c05e2d9301e6e91dc6ab6c3ca918f7d55896e1f1edd64adc0e615cde27ebf1::comparator {
    struct Result has drop {
        inner: u8,
    }
    
    public fun compare<T0>(arg0: &T0, arg1: &T0) : Result {
        abort 0
    }
    
    public fun compare_u8_vector(arg0: vector<u8>, arg1: vector<u8>) : Result {
        abort 0
    }
    
    public fun is_equal(arg0: &Result) : bool {
        abort 0
    }
    
    public fun is_greater_than(arg0: &Result) : bool {
        abort 0
    }
    
    public fun is_smaller_than(arg0: &Result) : bool {
        abort 0
    }
    
    // decompiled from Move bytecode v6
}

