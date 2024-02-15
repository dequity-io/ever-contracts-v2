pragma ton-solidity >= 0.58.1;

import 'collection.h';
import 'OwnableInternal.sol';
import 'IUserProfileRoot.sol';
import 'UserProfile.sol';

contract UserProfileRoot is IUserProfileRoot, TIP4_2Collection, TIP4_3Collection, OwnableInternal {

    uint16 constant VALUE_IS_LESS_THAN_REQUIRED = 1001;
    uint16 constant MINIMUM_CONTRACT_BALANCE = 1002;
    uint16 constant SENDER_IS_NOT_PROFILE = 1003;

    uint128 constant PROCESSING_VALUE = 0.3 ever;
    uint128 constant MIN_CONTRACT_BALANCE = 1 ever;

    uint128 _remainOnNft = 0.3 ever;
    uint128 _setKYCValue = 0.3 ever;
    uint128 _mintingFee;

    constructor(TvmCell codeNft, TvmCell codeIndex,TvmCell codeIndexBasis, address owner,string json, uint128 mintFee) OwnableInternal(owner) TIP4_1Collection (codeNft) TIP4_2Collection (json) TIP4_3Collection (codeIndex,codeIndexBasis) {
        tvm.accept();
        _mintingFee = mintFee;
        _supportedInterfaces[bytes4(tvm.functionId(IUserProfileRoot.mint)) ^bytes4(tvm.functionId(IUserProfileRoot.setKYC)) ^bytes4(tvm.functionId(IUserProfileRoot.withdraw)) ^ bytes4(tvm.functionId(IUserProfileRoot.setRemainOnNft)) ^bytes4(tvm.functionId(IUserProfileRoot.setKYCValue)) ^ bytes4(tvm.functionId(IUserProfileRoot.setMintingFee)) ^ bytes4(tvm.functionId(IUserProfileRoot.mintingFee)) ] = true;
    }

    function mint(string json) external override virtual {
        require(msg.value >= getGasFee(), VALUE_IS_LESS_THAN_REQUIRED );
        tvm.rawReserve(_mintingFee, 4);
        uint256 id = msg.sender.value;
        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, id);
        new UserProfile{stateInit: stateNft,value: 0,flag: 128}( msg.sender, msg.sender, _remainOnNft, json, _indexDeployValue, _indexDestroyValue, _codeIndex ); 
    }

    function onMint(uint256 id,address owner,address manager) external virtual override {
        require(msg.sender == _resolveNft(id), SENDER_IS_NOT_PROFILE);
        tvm.rawReserve(0, 4);
        _totalSupply++;
        emit NftCreated(id, msg.sender,owner,manager, owner);
        owner.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function setKYC(uint256 id) external virtual override onlyOwner {
        require(msg.value >= _setKYCValue);
        tvm.rawReserve(0, 4);
        address userProfile = _resolveNft(id);
        IUserProfile(userProfile).setKYC{value: 0, bounce: true, flag: 128}();
    }

    function withdraw(address dest, uint128 value) external virtual override onlyOwner {
        require(address(this).balance - value > MIN_CONTRACT_BALANCE, MINIMUM_CONTRACT_BALANCE);
        tvm.rawReserve(value + msg.value, 12);
        dest.transfer({value: value, bounce: false, flag: 0 + 1});
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function setRemainOnNft(uint128 remainOnNft) external virtual override onlyOwner {
        tvm.rawReserve(0, 4);
        _remainOnNft = remainOnNft;
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function setKYCValue(uint128 val) external virtual override onlyOwner {
        tvm.rawReserve(0, 4);
        _setKYCValue = val;
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function setMintingFee(uint128 fee) external virtual override onlyOwner {
        tvm.rawReserve(0, 4);
        _mintingFee = fee;
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function getRemainOnNft() external virtual override responsible view returns(uint128 remainOnNft) {
        return{value: 0, bounce: false, flag: 64} _remainOnNft;
    }

    function getKYCValue() external virtual override responsible view returns(uint128 KYCValue) {
        return{value: 0, bounce: false, flag: 64} _setKYCValue;
    }

    function getGasFee() public virtual override responsible view returns(uint128 mintGasFee) {
        return{value: 0,flag: 64,bounce: false}((_remainOnNft + _mintingFee + (2 * _indexDeployValue) + PROCESSING_VALUE + SEND_CALLBACK_TO_ROOT_VALUE));
    }

    function mintingFee() external view virtual override responsible returns(uint128) {
        return {value: 0, flag: 64, bounce: false}(_mintingFee);
    }

    function _isOwner() internal virtual override onlyOwner returns(bool){
        return true;
    }

    function _buildNftState(TvmCell code,uint256 id) internal virtual override(TIP4_2Collection, TIP4_3Collection) pure returns (TvmCell) {
        return tvm.buildStateInit({contr: UserProfile,varInit: {_id: id},code: code});
    }

}
