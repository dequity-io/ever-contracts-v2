pragma ton-solidity >= 0.58.1;

import "nft.h";
import 'IRoyalty.sol';

abstract contract Royalty is IRoyalty, TIP6 {

    uint8 private _royalty;
    address private  _royaltyReceiver;

    constructor(uint8 royalty, address royaltyReceiver) {
        _royalty = royalty;
        _royaltyReceiver = royaltyReceiver;
        _supportedInterfaces[bytes4(tvm.functionId(IRoyalty.getRoyaltyInfo))] = true;
    }

    function getRoyaltyInfo() public virtual view override responsible returns(uint8 royalty, address receiver) {
        return{ value: 0, flag: 64, bounce: false } (_royalty, _royaltyReceiver);
    }

}