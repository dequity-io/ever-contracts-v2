pragma ton-solidity >= 0.58.0;

import 'IIndexBasis.sol';

contract IndexBasis is IIndexBasis {

    address static _collection;

    modifier onlyCollection() {
        require(msg.sender == _collection, 101, "Method for collection only");
        tvm.accept();
        _;
    }
    constructor() onlyCollection {}

    function getInfo() override public view responsible returns (address collection) {
        return {value: 0, flag: 64, bounce: true} _collection;
    }

    function destruct(address gasReceiver) override public onlyCollection {
        selfdestruct(gasReceiver);
    }
}