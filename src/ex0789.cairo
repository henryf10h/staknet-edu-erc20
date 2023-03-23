// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address


from openzeppelin.token.erc20.library import ERC20
from openzeppelin.access.ownable.library import Ownable

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, owner: felt
) {
    ERC20.initializer('MyToken', 'HOMK', 18);
    Ownable.initializer(owner);

    ERC20._mint(recipient, Uint256(2000000000000000000000, 0));
    return ();
}

//
// Storage variables
//

@storage_var
func is_allowed(address : felt) -> (is_allowed : felt) {
}

//
// Getters
//

@view
func allowlist_level{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) -> (is_true: felt) {
    let (is_true) = is_allowed.read(address);
    return (is_true = is_true);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return ERC20.name();
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return ERC20.symbol();
}

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (totalSupply: Uint256) {
    let (totalSupply) = ERC20.total_supply();
    return (totalSupply=totalSupply);
}

@view
func decimals{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (decimals: felt) {
    return ERC20.decimals();
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (balance: Uint256) {
    return ERC20.balance_of(account);
}

@view
func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, spender: felt
) -> (remaining: Uint256) {
    return ERC20.allowance(owner, spender);
}

@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    return Ownable.owner();
}

//
// Externals
//

@external
func request_allowlist_level{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(level : felt) -> (is_listed : felt) {
    let (sender) = get_caller_address();
    is_allowed.write(sender,level);
    let (is_listed) = is_allowed.read(sender);
    return (is_listed = is_listed);
}

@external
func get_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (amount: Uint256) {
    let (sender) = get_caller_address();
    let (is_true) = is_allowed.read(sender);
    let amt : Uint256 = Uint256(0,0);
    if (is_true == 1){
        let amt : Uint256 = Uint256(1,0);
        ERC20._mint(sender,  amt);
        return (amount = Uint256(1,0));
    }
    if (is_true == 2){
        let amt : Uint256 = Uint256(2,0);
        ERC20._mint(sender,  amt);
        return (amount = Uint256(2,0));
    }
    return(amount=amt);
}

@external
func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.transfer(recipient, amount);
}

@external
func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    sender: felt, recipient: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.transfer_from(sender, recipient, amount);
}

@external
func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, amount: Uint256
) -> (success: felt) {
    return ERC20.approve(spender, amount);
}

@external
func increaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, added_value: Uint256
) -> (success: felt) {
    return ERC20.increase_allowance(spender, added_value);
}

@external
func decreaseAllowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    spender: felt, subtracted_value: Uint256
) -> (success: felt) {
    return ERC20.decrease_allowance(spender, subtracted_value);
}

@external
func transferOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    newOwner: felt
) {
    Ownable.transfer_ownership(newOwner);
    return ();
}

@external
func renounceOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Ownable.renounce_ownership();
    return ();
}

//
// Internals
//

func assert_only_allowed{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}() {
    let (sender_address) = get_caller_address();
    let (is_true) = is_allowed.read(sender_address);
    with_attr error_message("Caller is not allowed") {
        assert is_true = 1;
    }
    return ();
}