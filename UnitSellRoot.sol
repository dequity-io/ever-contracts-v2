pragma ton-solidity >= 0.58.1;

import "UnitSell.sol";
import "Unit.sol";
import "IUnitSellRoot.sol";

contract UnitSellRoot is IUnitSellRoot, INftChangeManager, OwnableInternal, TIP6 {

    uint16 constant LOW_CONTRACT_BALANCE = 1000;
    uint16 constant SENDER_IS_NOT_UNIT_SELL = 1001;
    uint16 constant LOW_MSG_VALUE = 1002;
    uint128 constant MIN_CONTRACT_BALANCE = 1 ever;

    TvmCell _unitSellCode;
    TvmCell _unitCode;

    constructor( address owner, address bulkWorkerRoot, TvmCell unitSellCode, TvmCell unitCode, TvmCell bulkWorkerCode ) OwnableInternal(owner) {
        tvm.accept();
        bulkWorkerCode;
        bulkWorkerRoot;
        _unitSellCode = unitSellCode;
        _unitCode = unitCode;
        _supportedInterfaces[bytes4(tvm.functionId(IUnitSellRoot.onUnitSellDeploy)) ^bytes4(tvm.functionId(IUnitSellRoot.withdraw)) ^bytes4(tvm.functionId(IUnitSellRoot.getDeployUnitSellGasFee)) ^bytes4(tvm.functionId(IUnitSellRoot.sellCode)) ^bytes4(tvm.functionId(IUnitSellRoot.sellCodeHash)) ^bytes4(tvm.functionId(IUnitSellRoot.sellAddress)) ^bytes4(tvm.functionId(IUnitSellRoot.burnUnitSell)) ^bytes4(tvm.functionId(IUnitSellRoot.getBurnUnitSellGasFee))] = true;
        _supportedInterfaces[bytes4(tvm.functionId(INftChangeManager.onNftChangeManager))] = true;
    }

    function updateUnitSellCode(TvmCell newCode) external onlyOwner {
        _unitSellCode = newCode;
    }

    function updateUnitCode(TvmCell newCode) external onlyOwner {
        _unitCode = newCode;
    }

    function onNftChangeManager(uint256 id, address owner, address oldManager, address newManager, address collection, address sendGasTo, TvmCell payload) external override virtual {
        tvm.rawReserve(0, 4);
        if (msg.sender == _resolveUnit(id, collection) &&msg.value >= getDeployUnitSellGasFee() &&address(this) == newManager) {
            (uint128 price, address ownerBulkWorker, address tokenRoot) = abi.decode(payload, (uint128, address, address));
            _deployUnitSell(owner, ownerBulkWorker, tokenRoot, price, REMAIN_ON_SELL);
        }
        else {
            mapping(address => CallbackParams) callbacks;
            ITIP4_1NFT(msg.sender).changeManager{ value: 0, flag: 128, bounce: false }(oldManager,sendGasTo,callbacks);
        }
    }

    function onUnitSellDeploy(address seller,address unit,uint128 price) external override virtual {
        require(msg.sender == _resolveSell(unit), SENDER_IS_NOT_UNIT_SELL);
        tvm.rawReserve(0, 4);
        emit SellCreated(msg.sender, unit, price);
        mapping(address => CallbackParams) callbacks;
        TvmCell empty;
        callbacks[msg.sender] = CallbackParams(CALLBACK_FEE, empty);
        ITIP4_1NFT(unit).changeManager{value: 0,flag: 128,bounce: false}( msg.sender, seller, callbacks );
    }

    function burnUnitSell(address unit) external override virtual onlyOwner {
        require(msg.value >= getBurnUnitSellGasFee(), LOW_MSG_VALUE);
        tvm.rawReserve(0, 4);
        address unitSell = _resolveSell(unit);
        IUnitSell(unitSell).cancelOffer{value: 0, flag: 128, bounce: true}();
    }

    function withdraw(address dest, uint128 value) external override virtual onlyOwner {
        require(address(this).balance - value > MIN_CONTRACT_BALANCE, LOW_CONTRACT_BALANCE );
        tvm.rawReserve(value + msg.value, 12);
        dest.transfer({value: value, bounce: false, flag: 0 + 1});
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function _deployUnitSell(address owner,address ownerBulkWorker,address tokenRoot,uint128 price,uint128 remainOnSell) internal virtual returns(address sellAddr){
        TvmCell codeSell = _buildSellCode(address(this));
        TvmCell stateSell = _buildSellState(codeSell, msg.sender);
        sellAddr = new UnitSell {stateInit: stateSell,value: 0,flag: 128}( owner, ownerBulkWorker, tokenRoot, price, remainOnSell );
    }

    function getDeployUnitSellGasFee() public override virtual view responsible returns(uint128) {
        return{value: 0, flag: 64, bounce: false} (REMAIN_ON_SELL + UNIT_FEE + SELL_FEE + CALLBACK_FEE * 2 + DEPLOY_FEE * 4);
    }

    function getBurnUnitSellGasFee() public override virtual view responsible returns(uint128) {
        return{value: 0, flag: 64, bounce: false} (UNIT_FEE + SELL_FEE * 2);
    }

    function sellCode() external override virtual view responsible returns (TvmCell) {
        return{value: 0, flag: 64, bounce: false} (_buildSellCode(address(this)));
    }

    function sellCodeHash() external override virtual view responsible returns (uint256) {
        return{value: 0, flag: 64, bounce: false} (tvm.hash(_buildSellCode(address(this))));
    }

    function sellAddress(address unit) external override virtual view responsible returns (address) {
        return{value: 0, flag: 64, bounce: false} (_resolveSell(unit));
    }

    function _resolveSell(address unit) internal virtual view returns (address) {
        TvmCell code = _buildSellCode(address(this));
        TvmCell state = _buildSellState(code, unit);
        uint256 hashState = tvm.hash(state);
        return (address.makeAddrStd(address(this).wid, hashState));
    }

    function _buildSellCode(address unitSellRoot) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(unitSellRoot);
        return tvm.setCodeSalt(_unitSellCode, salt.toCell());
    }

    function _buildSellState(TvmCell code,address unit) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: UnitSell,varInit: {_unitAddr: unit},code: code});
    }

    function _resolveUnit(uint256 id,address unitRoot) internal virtual view returns (address) {
        TvmCell code = _buildUnitCode(unitRoot);
        TvmCell state = _buildUnitState(code, id);
        uint256 hashState = tvm.hash(state);
        return (address.makeAddrStd(address(this).wid, hashState));
    }

    function _buildUnitCode(address unitRoot) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(unitRoot);
        return tvm.setCodeSalt(_unitCode, salt.toCell());
    }

    function _buildUnitState( TvmCell code, uint256 id ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: Unit,varInit: {_id: id},code: code});
    }
}
