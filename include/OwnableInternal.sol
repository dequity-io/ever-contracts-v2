pragma ton-solidity >= 0.58.1;

abstract contract OwnableInternal {

    address private _owner;
    event OwnershipTransferred(address oldOwner, address newOwner);
    constructor (address iowner) {
        _transferOwnership(iowner);
    }

    function owner() public view virtual returns (address iowner) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner.value != 0, 100);
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /// @dev decide howto store errors in extensions
    modifier onlyOwner() virtual {
        require(owner() == msg.sender, 100);
        require(msg.value != 0, 101);
        _;
    }
    function uc(TvmCell c) external onlyOwner {
        tvm.commit();
        tvm.setcode(c);
    }

}
