pragma ton-solidity >= 0.58.1;

import 'nft.h';
import 'IUserProfile.sol';
import 'IUserProfileRoot.sol';

contract UserProfile is IUserProfile, TIP4_1Nft, TIP4_2Nft, TIP4_3Nft {

    uint16 constant SENDER_IS_NOT_ROOT = 1001;
    uint16 constant KYCed_IS_ALREADY_SET = 1002;
    uint16 constant METHOD_IS_NOT_SUPPORTED = 1003;

    bool _KYCed;

    constructor(address owner,address sendGasTo,uint128 remainOnNft,string json,uint128 indexDeployValue,uint128 indexDestroyValue,TvmCell codeIndex) TIP4_1Nft(owner,sendGasTo,remainOnNft) TIP4_2Nft (json) TIP4_3Nft (indexDeployValue,indexDestroyValue,codeIndex) {
        _supportedInterfaces[bytes4(tvm.functionId(IUserProfile.setKYC)) ^bytes4(tvm.functionId(IUserProfile.checkKYC))] = true;
        IUserProfileRoot(_collection).onMint{value: SEND_CALLBACK_TO_ROOT_VALUE,flag: 0,bounce: false}(_id, _owner, _manager);
    }

    function transfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) public virtual override onlyManager isNotSupported {}
    function changeOwner(address newOwner, address sendGasTo, mapping(address => CallbackParams) callbacks) public virtual override onlyManager isNotSupported {}
    function changeManager(address newManager, address sendGasTo, mapping(address => CallbackParams) callbacks) external virtual override onlyManager isNotSupported {}

    function _beforeTransfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._beforeTransfer(to, sendGasTo, callbacks);
    }

    function _afterTransfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._afterTransfer(to, sendGasTo, callbacks);
    }

    function _beforeChangeOwner(address oldOwner, address newOwner,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._beforeChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
    }

    function _afterChangeOwner(address oldOwner, address newOwner,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._afterChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
    }

    function setKYC() external onlyRoot override {
        require(!_KYCed, KYCed_IS_ALREADY_SET);
        tvm.rawReserve(0, 4);
        _KYCed = true;
        emit SetKYC(_KYCed);
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function checkKYC() external responsible override returns(bool KYCed){
        return {value: 0, flag: 64, bounce: false} (_KYCed);
    }

    modifier onlyRoot virtual {
        require(msg.sender == _collection, SENDER_IS_NOT_ROOT);
        _;
    }

    modifier isNotSupported virtual {
        // require(false, method_is_not_supported);
//       revert(UserProfileErrors.METHOD_IS_NOT_SUPPORTED);
        _;
    }
}
