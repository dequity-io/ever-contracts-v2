pragma ton-solidity >= 0.58.1;

import "OwnableInternal.sol";
import "nft.h";
import 'IToken.h';
import "IUnitSellRoot.sol";
import "IUnitSell.sol";
import "ICertificate.sol";
import 'IRoyalty.sol';

interface ISellStatus {
    function getStatusType() external view responsible returns (SellStatusType);
}
enum SellStatusType {READY,PENDING}
abstract contract SellStatus is ISellStatus {
    SellStatusType private _status;
    event changeSellStatus(SellStatusType oldStatus, SellStatusType newStatus);
    function _setStatusType(SellStatusType status) internal virtual {
        emit changeSellStatus(_status, status);
        _status = status;
    }
    function getStatusType() public virtual view override responsible returns (SellStatusType) {
        return { value: 0, flag: 64, bounce: false } (_status);
    }
}

contract UnitSell is IUnitSell, IAcceptTokensTransferCallback, INftChangeManager, OwnableInternal, TIP6, SellStatus {

    uint16 constant SALT_IS_EMPTY = 1000;
    uint16 constant WRONG_SENDER = 1001;
    uint16 constant SENDER_IS_NOT_SELLROOT = 1002;
    uint16 constant MSG_VALUE_IS_TOO_LOW = 1003;
    uint16 constant STATUS_NOT_READY = 1004;
    uint16 constant SENDER_IS_NOT_TOKEN_ROOT = 1005;
    uint16 constant SENDER_IS_NOT_TOKEN_WALLET = 1006;
    uint16 constant TOKEN_WALLET_NOT_EXIST = 1007;
    uint16 constant WRONG_TIP3_TOKENS_VALUE_RECEIVE = 1008;
    uint16 constant SENDER_IS_NOT_UNIT = 1009;

    address static _unitAddr;
    address _unitSellRootAddr;
    address _tokenRoot;
    address _tokenWallet;
    uint128 _price;
    address _ownerBulkWorker;
    uint8 _royalty;
    address _royaltyReceiver;

    constructor(address owner, address ownerBulkWorker, address tokenRoot, uint128 price, uint128 remainOnSell) OwnableInternal(owner) {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require (optSalt.hasValue(), SALT_IS_EMPTY);
        address unitSellRootAddr = optSalt.get().toSlice().load(address);
        require (msg.sender == unitSellRootAddr, SENDER_IS_NOT_SELLROOT);
        tvm.rawReserve(remainOnSell, 0);
        _tokenRoot = tokenRoot;
        _price = price;
        _ownerBulkWorker = ownerBulkWorker;
        _unitSellRootAddr = unitSellRootAddr;
        SellStatus._setStatusType(SellStatusType.PENDING);
        _supportedInterfaces[bytes4(tvm.functionId(IUnitSell.cancelOffer)) ^ bytes4(tvm.functionId(IUnitSell.getOfferInfo)) ^ bytes4(tvm.functionId(IUnitSell.getConfirmOfferGas)) ^ bytes4(tvm.functionId(IUnitSell.getCancelOfferGas)) ] = true;
        _supportedInterfaces[bytes4(tvm.functionId(IAcceptTokensTransferCallback.onAcceptTokensTransfer))] = true;
        _supportedInterfaces[bytes4(tvm.functionId(INftChangeManager.onNftChangeManager))] = true;
        ITokenRoot(_tokenRoot).deployWallet{ value: DEPLOY_FEE * 2, bounce: true, flag: 0, callback: IUnitSell.onUnitSellTokenWalletDeploy }(address(this), DEPLOY_FEE);
        IRoyalty(_unitAddr).getRoyaltyInfo{  value: DEPLOY_FEE * 2 + CALLBACK_FEE, bounce: true, flag: 0, callback: IUnitSell.onGetUnitRoyalty }();
        IUnitSellRoot(_unitSellRootAddr).onUnitSellDeploy{ value: 0, flag: 128, bounce: false }( OwnableInternal.owner(), _unitAddr, _price );
    }

    function onUnitSellTokenWalletDeploy(address tokenWallet) external virtual override {
        require (msg.sender == _tokenRoot, SENDER_IS_NOT_TOKEN_ROOT );
        tvm.rawReserve(0, 4);
        _tokenWallet = tokenWallet;
        OwnableInternal.owner().transfer({value: 0, flag: 128 + 2, bounce: false});
    }

    function onOwnerTokenWalletDeploy(address tokenWallet) external virtual override {
        tokenWallet;
        require (msg.sender == _tokenRoot, SENDER_IS_NOT_TOKEN_ROOT );
        tvm.rawReserve(0, 4);
        OwnableInternal.owner().transfer({value: 0, flag: 128 + 2, bounce: false});
    }

    function onGetUnitRoyalty(uint8 royalty, address royaltyReceiver) external virtual override {
        require (msg.sender == _unitAddr, SENDER_IS_NOT_UNIT );
        tvm.rawReserve(0, 4);
        _royalty = royalty;
        _royaltyReceiver = royaltyReceiver;
        OwnableInternal.owner().transfer({value: 0, flag: 128 + 2, bounce: false});
    }

    function onNftChangeManager(uint256 id, address owner, address oldManager, address newManager, address collection, address sendGasTo, TvmCell payload) external override virtual {
        id;collection;payload;
        tvm.rawReserve(0, 4);
        if( msg.sender == _unitAddr && owner == OwnableInternal.owner() && address(this) == newManager ) {
            SellStatus._setStatusType(SellStatusType.READY);
            emit OfferReady(_unitAddr, OwnableInternal.owner(), _price);
            sendGasTo.transfer({value: 0, bounce: false, flag: 128 + 2});
        }
        else {
            mapping(address => CallbackParams) callbacks;
            ITIP4_1NFT(msg.sender).changeManager{ value: 0, flag: 128 + 2, bounce: false }( oldManager, sendGasTo, callbacks );
        }
    }

    function onAcceptTokensTransfer(address tokenRoot,uint128 amount,address sender,address senderWallet,address remainingGasTo,TvmCell payload) external override virtual {
        tokenRoot;sender;senderWallet;
        require (msg.sender == _tokenWallet && _tokenWallet.value != 0, SENDER_IS_NOT_TOKEN_WALLET);
        require (msg.value >= getConfirmOfferGas(), MSG_VALUE_IS_TOO_LOW );
        require (amount == _price, WRONG_TIP3_TOKENS_VALUE_RECEIVE );
        require (SellStatus.getStatusType() == SellStatusType.READY, STATUS_NOT_READY );
        tvm.accept();
        address to = abi.decode(payload, address);
        mapping(address => CallbackParams) callbacks;
        ITIP4_1NFT(_unitAddr).transfer{ value: SELL_FEE, flag: 1, bounce: false }( to, to, callbacks );
        emit OfferConfirmed(_unitAddr, OwnableInternal.owner(), to, _price);
        uint128 royaltyTokensAmount = 0;
        if (_royalty > 0)
            royaltyTokensAmount = uint128(uint(uint(_price) * uint(_royalty)) / uint(100));
        TvmCell empty;
        ITokenWallet(_tokenWallet).transfer{ value: CALLBACK_FEE, flag: 0, bounce: false}(_price - royaltyTokensAmount, OwnableInternal.owner(), 0, remainingGasTo, false, empty );
        if (royaltyTokensAmount > 0)
            ITokenWallet(_tokenWallet).transfer{value: CALLBACK_FEE + DEPLOY_FEE, flag: 0, bounce: false}(royaltyTokensAmount, _royaltyReceiver, DEPLOY_FEE, remainingGasTo, false, empty );
        to.transfer({value: 0, flag: 128 + 32, bounce: false});
    }

    function cancelOffer() external virtual override {
        require (msg.sender == OwnableInternal.owner() ||  msg.sender == _ownerBulkWorker ||  msg.sender == _unitAddr || msg.sender == _unitSellRootAddr, WRONG_SENDER );
        if (msg.sender == _unitAddr)
            require (msg.value >= SELL_FEE, MSG_VALUE_IS_TOO_LOW);
        else
            require (msg.value >= getCancelOfferGas(),  MSG_VALUE_IS_TOO_LOW);
        require (SellStatus.getStatusType() == SellStatusType.READY, STATUS_NOT_READY);
        tvm.accept();
        if (msg.sender == _unitAddr)
            ICertificate(_unitAddr).onCancelOfferCallback{value: 0, flag: 128 + 32, bounce: false}();
        else {
            mapping(address => CallbackParams) callbacks;
            ITIP4_1NFT(_unitAddr).changeManager { value: UNIT_FEE, flag: 1, bounce: false }(OwnableInternal.owner(), OwnableInternal.owner(), callbacks);
            OwnableInternal.owner().transfer({value: 0, flag: 128 + 32, bounce: false});
        }
        emit OfferCanceled(_unitAddr, OwnableInternal.owner(), _price);
    }

    function getOfferInfo() public virtual override view responsible returns( address unit, address seller, address unitSellRoot, address tokenWallet, uint128 price ) {
        return{value: 0, flag: 64, bounce: false} ( _unitAddr, OwnableInternal.owner(), _unitSellRootAddr, _tokenWallet, _price );
    }

    function getConfirmOfferGas() public virtual override view responsible returns(uint128) {
        return{value: 0, flag: 64, bounce: false} (SELL_FEE * 2 + CALLBACK_FEE);
    }

    function getCancelOfferGas() public virtual override view responsible returns(uint128) {
        return{value: 0, flag: 64, bounce: false} (UNIT_FEE + SELL_FEE);
    }
}