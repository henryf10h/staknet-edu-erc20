// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_sub
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from openzeppelin.token.erc20.IERC20 import IERC20
from src.IDTKERC20 import IDTKERC20

// constructor

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}( _dummy_token_address: felt) {
    dummy_token_address_storage.write(_dummy_token_address);
    return ();
}

/// variables

@storage_var
func dummy_token_address_storage() -> (dummy_token_address_storage: felt) {
}

@storage_var
func balance_of(address:felt) -> (amt: Uint256) {
}

// view

@view
func dummy_token_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    account: felt
) {
    let (address) = dummy_token_address_storage.read();
    return (account = address);
}

@view
func tokens_in_custody{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address:felt) -> (amount:Uint256){
    let (sender) = get_caller_address();
    let (amount) = balance_of.read(sender);
    return(amount = amount);

}

// external

@external
func get_tokens_from_contract{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (amount : Uint256) {
    alloc_locals;

    let (sender) = get_caller_address();
    let (contract) = get_contract_address();
    let (dtk) = dummy_token_address();
    
    let (token_amount_init) = IDTKERC20.balanceOf(dtk, contract);
    IDTKERC20.faucet(dtk);
    let (token_amount_fin) = IDTKERC20.balanceOf(dtk, contract);
    let (custody_difference) = uint256_sub(token_amount_fin, token_amount_init);

    balance_of.write(sender,custody_difference);

    return(amount=custody_difference);
}

@external
func withdraw_all_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}()->(amt:Uint256) {
    alloc_locals;

    let (sender) = get_caller_address();
    let (contract) = get_contract_address();
    let (dtk) = dummy_token_address();
    let (balance) = tokens_in_custody(sender);

    balance_of.write(sender,Uint256(0,0));
    IDTKERC20.transfer(dtk,sender,balance);

    return(amt=balance);
}