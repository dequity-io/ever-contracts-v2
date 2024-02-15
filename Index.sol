pragma ton-solidity >= 0.58.0;

import 'IIndex.sol';
contract Index is IIndex {
    address static _nft;
    address _collection;
    address _owner;

    constructor(address collection) {
        optional(TvmCell) salt = tvm.codeSalt(tvm.code());
        require(salt.hasValue(), 102, "Salt doesn't contain any value");
        (, address collection_, address owner) = salt.get().toSlice().load(string, address, address);
        require(msg.sender == _nft);
        tvm.accept();
        _collection = collection_;
        _owner = owner;
        if (collection_.value == 0)
            _collection = collection;
    }

    function getInfo() override public view responsible returns ( address collection, address owner, address nft ) {
        return {value: 0, flag: 64, bounce: true} (_collection,_owner,_nft);
    }

    function destruct(address gasReceiver) override public {
        require(msg.sender == _nft, 101, "Method for NFT only");
        selfdestruct(gasReceiver);
    }
}