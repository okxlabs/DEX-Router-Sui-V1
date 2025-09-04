module lsd::record {
	struct PendingUnstakeRecord has drop, store {
		requester: std::option::Option<address>,
		afsui_amount: u64,
		afsui_id: sui::object::ID
	}
}