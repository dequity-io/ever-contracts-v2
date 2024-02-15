pragma ton-solidity >= 0.58.1;

import "IToken.h";
import "IDistributionsWallet.sol";
import "Unit.sol";

uint128 constant REMAIN_ON_WALLET = 0.3 ever;

abstract contract Checks {
    uint8 _checkList;
    constructor(uint8 checkList) {
        _checkList = checkList;
    }
    function _passCheck(uint8 check) internal virtual {
        _checkList &= ~check;
    }
    function _isCheckListEmpty() internal virtual view returns (bool) {
        return (_checkList == 0);
    }
}

contract DistributionsWallet is IDistributionsWallet, Checks, TIP6, IAcceptTokensTransferCallback {

    uint8 constant CHECK_TIP3_WALLET = 1;

    uint16 constant NOT_TIP3_TOKEN_ROOT = 1001;
    uint16 constant NOT_PROPERTY = 1002;
    uint16 constant NON_ZERO_ADDRESS = 1003;
    uint16 constant VALUE_IS_TOO_LOW = 1004;
    uint16 constant SENDER_IS_NOT_VALID_UNIT = 1005;
    uint16 constant VALUE_MUST_BE_GREATER_THAN_0 = 1006;

    address static _property;
    TvmCell _unitCode;
    address _unitRoot;
    address _tip3TokenRoot;
    address _tip3Wallet;
    uint128 _numOfUnits;
    uint128 _unitReward;
    uint128 _undistributedBalance;

    constructor( address unitRoot, address tip3TokenRoot, uint128 numOfUnits, TvmCell unitCode ) Checks(CHECK_TIP3_WALLET) {
        tvm.rawReserve(REMAIN_ON_WALLET, 0);
        require(_property.value != 0, NON_ZERO_ADDRESS);
        require(msg.sender == _property, NOT_PROPERTY);
        require(tip3TokenRoot.value != 0, NON_ZERO_ADDRESS);
        require(numOfUnits > 0, VALUE_MUST_BE_GREATER_THAN_0);
        require(msg.value >= REMAIN_ON_WALLET + DEPLOY_FEE, VALUE_IS_TOO_LOW);

        _unitRoot = unitRoot;
        _unitCode = unitCode;
        _tip3TokenRoot = tip3TokenRoot;
        _numOfUnits = numOfUnits;

        _supportedInterfaces[bytes4(tvm.functionId(IDistributionsWallet.unitAddress)) ^bytes4(tvm.functionId(IDistributionsWallet.getInfo)) ^bytes4(tvm.functionId(IDistributionsWallet.transfer)) ] = true;
        _supportedInterfaces[bytes4(tvm.functionId(IAcceptTokensTransferCallback.onAcceptTokensTransfer))] = true;
        ITokenRoot(_tip3TokenRoot).deployWallet{ value: 0, flag: 128 + 2, callback: DistributionsWallet.onDeployTIP3Wallet, bounce: true }(address(this), DEPLOY_FEE);
    }

    function onDeployTIP3Wallet(address tip3Wallet) external {
        tvm.rawReserve(0, 4);
        require(msg.sender == _tip3TokenRoot, NOT_TIP3_TOKEN_ROOT);
        _tip3Wallet = tip3Wallet;
        _passCheck(CHECK_TIP3_WALLET);
    }

    function onAcceptTokensTransfer( address tokenRoot, uint128 amount, address sender, address senderWallet, address remainingGasTo, TvmCell payload ) external override {
        sender;payload;
        tvm.rawReserve(0, 4);
        if (_isCheckListEmpty() && msg.sender == _tip3Wallet && _tip3TokenRoot == tokenRoot) {
            _distribute(amount);
        } else {
            TvmCell empty;
            ITokenWallet(_tip3Wallet).transferToWallet{ value: 0, flag: 128, bounce: false }(amount,senderWallet,remainingGasTo,true,empty);
        }
    }

    function _distribute(uint128 amount) internal {
        uint128 _undistributedValue = _undistributedBalance + amount;
        uint128 unitReward = _undistributedValue / _numOfUnits;
        _unitReward += unitReward;
        _undistributedBalance = _undistributedValue - (unitReward * _numOfUnits);
    }

    function transfer( uint256 id, uint128 withdrawnAmt, uint128 pendingAmt, address to, address sendGasTo ) external override {
        tvm.rawReserve(0, 4);
        require(msg.sender == _unitAddress(id), SENDER_IS_NOT_VALID_UNIT);
        require(pendingAmt > 0, VALUE_IS_TOO_LOW);
        require(_unitReward - withdrawnAmt >= pendingAmt, VALUE_IS_TOO_LOW);
        _transfer(to, pendingAmt, sendGasTo);
        emit WithdrawDistributedTokens(_property, msg.sender, to, pendingAmt);
        sendGasTo.transfer({value: 0, flag: 128 + 2});
    }

    function _transfer(address to, uint128 amount, address sendGasTo) internal view {
        TvmCell empty;
        ITokenWallet(_tip3Wallet).transfer{ value: UNIT_FEE, flag: 0 + 1, bounce: false }( amount, to, DEPLOY_FEE, sendGasTo, false, empty );
    }

    function getInfo() external responsible override returns( address property, address unitRoot, address tip3TokenRoot, address tip3Wallet, uint128 numOfUnits, uint128 unitReward, uint128 undistributedBalance ) {
        return {value: 0, flag: 64, bounce: false} (_property,_unitRoot,_tip3TokenRoot,_tip3Wallet,_numOfUnits,_unitReward,_undistributedBalance);
    }
    function unitAddress(uint256 id) external view virtual override responsible returns (address unit) {
        return {value: 0, flag: 64, bounce: false} _unitAddress(id);
    }

    function _unitAddress(uint256 id) internal view returns(address unit) {
        TvmCell code = _buildUnitCode();
        TvmCell state = _buildUnitState(code, id);
        uint256 hashState = tvm.hash(state);
        return address.makeAddrStd(address(this).wid, hashState);
    }

    function _buildUnitCode() internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(_unitRoot);
        return tvm.setCodeSalt(_unitCode, salt.toCell());
    }

    function _buildUnitState(TvmCell code,uint256 id) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: Unit,varInit: {_id: id},code: code});
    }
}