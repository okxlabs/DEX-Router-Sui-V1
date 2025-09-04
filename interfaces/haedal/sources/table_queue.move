module 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::table_queue {
    struct TableQueue<phantom T0: store> has store {
        head: u64,
        tail: u64,
        contents: 0x2::table::Table<u64, T0>,
    }
    
    public fun borrow<T0: store>(arg0: &TableQueue<T0>, arg1: u64) : &T0 {
        abort 0
    }
    
    public fun borrow_mut<T0: store>(arg0: &mut TableQueue<T0>, arg1: u64) : &mut T0 {
        abort 0
    }
    
    public fun destroy_empty<T0: store>(arg0: TableQueue<T0>) {
        abort 0
    }
    
    public fun empty<T0: store>(arg0: &mut 0x2::tx_context::TxContext) : TableQueue<T0> {
        abort 0
    }
    
    public fun length<T0: store>(arg0: &TableQueue<T0>) : u64 {
        abort 0
    }
    
    public fun push_back<T0: store>(arg0: &mut TableQueue<T0>, arg1: T0) {
        abort 0
    }
    
    public fun is_empty<T0: store>(arg0: &TableQueue<T0>) : bool {
        abort 0
    }
    
    public fun borrow_front<T0: store>(arg0: &TableQueue<T0>) : &T0 {
        abort 0
    }
    
    public fun borrow_front_mut<T0: store>(arg0: &mut TableQueue<T0>) : &mut T0 {
        abort 0
    }
    
    public fun head<T0: store>(arg0: &TableQueue<T0>) : u64 {
        abort 0
    }
    
    public fun pop_front<T0: store>(arg0: &mut TableQueue<T0>) : T0 {
        abort 0
    }
    
    public fun tail<T0: store>(arg0: &TableQueue<T0>) : u64 {
        abort 0
    }
    
    // decompiled from Move bytecode v6
}

