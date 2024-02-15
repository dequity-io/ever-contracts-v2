pragma ever-solidity >= 0.72.0;

import "IToken.h";

uint16 constant NOT_OWNER = 1000;
uint16 constant NOT_ROOT = 1010;
uint16 constant WRONG_WALLET_OWNER = 1021;
uint16 constant WRONG_RECIPIENT = 1030;
uint16 constant NON_ZERO_PUBLIC_KEY = 1040;
uint16 constant WRONG_AMOUNT = 1050;
uint16 constant NOT_ENOUGH_BALANCE = 1060;
uint16 constant NON_EMPTY_BALANCE = 1070;
uint16 constant SENDER_IS_NOT_VALID_WALLET = 1100;

abstract contract TokenWalletBase is ITokenWallet {

    uint128 constant TARGET_WALLET_BALANCE = 0.1 ton;
    uint16 constant RECIPIENT_ALLOWS_ONLY_NOTIFIABLE = 1200;
    uint16 constant LOW_GAS_VALUE = 2000;
    uint16 constant DEPLOY_WALLET_VALUE_TOO_LOW = 2010;

    address static root_;
    address static owner_;
    uint128 balance_;
    modifier onlyRoot() {
        require(root_ == msg.sender, NOT_ROOT);
        _;
    }
    modifier onlyOwner() {
        require(owner_ == msg.sender, NOT_OWNER);
        _;
    }
    function balance() override external view responsible returns (uint128) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } balance_;
    }
    function owner() override external view responsible returns (address) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } owner_;
    }
    function root() override external view responsible returns (address) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } root_;
    }
    function walletCode() override external view responsible returns (TvmCell) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } tvm.code();
    }
    function transfer( uint128 amount, address recipient, uint128 deployWalletValue, address remainingGasTo, bool notify, TvmCell payload ) override external onlyOwner {
        require(amount > 0, WRONG_AMOUNT);
        require(amount <= balance_, NOT_ENOUGH_BALANCE);
        require(recipient.value != 0 && recipient != owner_, WRONG_RECIPIENT);
        tvm.rawReserve(_reserve(), 0);
        TvmCell stateInit = _buildWalletInitData(recipient);
        address recipientWallet;
        if (deployWalletValue > 0) {
            recipientWallet = _deployWallet(stateInit, deployWalletValue, remainingGasTo);
        } else {
            recipientWallet = address(tvm.hash(stateInit));
        }
        balance_ -= amount;
        ITokenWallet(recipientWallet).acceptTransfer{ value: 0, flag: ALL_NOT_RESERVED, bounce: true }( amount, owner_, remainingGasTo, notify, payload );
    }
    function transferToWallet( uint128 amount, address recipientTokenWallet, address remainingGasTo, bool notify, TvmCell payload ) override external onlyOwner {
        require(amount > 0, WRONG_AMOUNT);
        require(amount <= balance_, NOT_ENOUGH_BALANCE);
        require(recipientTokenWallet.value != 0 && recipientTokenWallet != address(this), WRONG_RECIPIENT);
        tvm.rawReserve(_reserve(), 0);
        balance_ -= amount;
        ITokenWallet(recipientTokenWallet).acceptTransfer{ value: 0, flag: ALL_NOT_RESERVED, bounce: true }( amount, owner_, remainingGasTo, notify, payload );
    }
    function acceptTransfer( uint128 amount, address sender, address remainingGasTo, bool notify, TvmCell payload ) override external functionID(0x67A0B95F) {
        require(msg.sender == address(tvm.hash(_buildWalletInitData(sender))), SENDER_IS_NOT_VALID_WALLET);
        tvm.rawReserve(_reserve(), 2);
        balance_ += amount;
        if (notify) {
            IAcceptTokensTransferCallback(owner_).onAcceptTokensTransfer{ value: 0, flag: ALL_NOT_RESERVED + IGNORE_ERRORS, bounce: false }( root_, amount, sender, msg.sender, remainingGasTo, payload );
        } else {
            remainingGasTo.transfer({ value: 0, flag: ALL_NOT_RESERVED + IGNORE_ERRORS, bounce: false });
        }
    }
    function acceptMint(uint128 amount, address remainingGasTo, bool notify, TvmCell payload) override external functionID(0x4384F298) onlyRoot {
        tvm.rawReserve(_reserve(), 2);
        balance_ += amount;
        if (notify) {
            IAcceptTokensMintCallback(owner_).onAcceptTokensMint{ value: 0, bounce: false, flag: ALL_NOT_RESERVED + IGNORE_ERRORS }( root_, amount, remainingGasTo, payload );
        } else if (remainingGasTo.value != 0 && remainingGasTo != address(this)) {
            remainingGasTo.transfer({ value: 0, flag: ALL_NOT_RESERVED + IGNORE_ERRORS, bounce: false });
        }
    }
    onBounce(TvmSlice body) external {
        tvm.rawReserve(_reserve(), 2);
        uint32 functionId = uint32(body.loadUint(32));
        if (functionId == tvm.functionId(ITokenWallet.acceptTransfer)) {
            uint128 amount = uint128(body.loadUint(128));
            balance_ += amount;
            IBounceTokensTransferCallback(owner_).onBounceTokensTransfer{ value: 0, flag: ALL_NOT_RESERVED + IGNORE_ERRORS, bounce: false }( root_, amount, msg.sender );
        } else if (functionId == tvm.functionId(ITokenRoot.acceptBurn)) {
            uint128 amount = uint128(body.loadUint(128));
            balance_ += amount;
            IBounceTokensBurnCallback(owner_).onBounceTokensBurn{ value: 0, flag: ALL_NOT_RESERVED + IGNORE_ERRORS, bounce: false }( root_, amount );
        }
    }
    function _burn( uint128 amount, address remainingGasTo, address callbackTo, TvmCell payload ) internal {
        require(amount > 0, WRONG_AMOUNT);
        require(amount <= balance_, NOT_ENOUGH_BALANCE);
        tvm.rawReserve(_reserve(), 0);
        balance_ -= amount;
        ITokenRoot(root_).acceptBurn{ value: 0, flag: ALL_NOT_RESERVED, bounce: true }( amount, owner_, remainingGasTo, callbackTo, payload );
    }
    function sendSurplusGas(address to) external view onlyOwner {
        tvm.rawReserve(_targetBalance(), 0);
        to.transfer({value: 0,flag: ALL_NOT_RESERVED + IGNORE_ERRORS,bounce: false});
    }
    function _reserve() internal pure returns (uint128) {
        return math.max(address(this).balance - msg.value, _targetBalance());
    }
    function _targetBalance() virtual internal pure returns (uint128);
    function _buildWalletInitData(address walletOwner) virtual internal view returns (TvmCell);
    function _deployWallet(TvmCell initData, uint128 deployWalletValue, address remainingGasTo) virtual internal view returns (address);
}

abstract contract TokenWalletBurnableBase is TokenWalletBase, IBurnableTokenWallet {
    function burn(uint128 amount, address remainingGasTo, address callbackTo, TvmCell payload) override external onlyOwner {
        _burn(amount, remainingGasTo, callbackTo, payload);
    }
}

abstract contract TokenWalletBurnableByRootBase is TokenWalletBase, IBurnableByRootTokenWallet {
    function burnByRoot(uint128 amount, address remainingGasTo, address callbackTo, TvmCell payload) override external onlyRoot {
        _burn(amount, remainingGasTo, callbackTo, payload);
    }
}
abstract contract TokenWalletDestroyableBase is TokenWalletBase, IDestroyable {
    function destroy(address remainingGasTo) override external onlyOwner {
        require(balance_ == 0, NON_EMPTY_BALANCE);
        remainingGasTo.transfer({ value: 0, flag: ALL_NOT_RESERVED + DESTROY_IF_ZERO, bounce: false });
    }
}

contract TokenWallet is TokenWalletBurnableBase, TokenWalletBurnableByRootBase, TokenWalletDestroyableBase {

    constructor() {
        require(tvm.pubkey() == 0, NON_ZERO_PUBLIC_KEY);
        require(owner_.value != 0, WRONG_WALLET_OWNER);
    }
    function supportsInterface(bytes4 interfaceID) override external view responsible returns (bool) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } (interfaceID == bytes4(0x3204ec29) || interfaceID == bytes4(0x4f479fa3) || interfaceID == bytes4(0x2a4ac43e) || interfaceID == bytes4(0x562548ad) || interfaceID == bytes4(0x0c2ff20d) || interfaceID == bytes4(0x0f0258aa));
    }

    function _targetBalance() override internal pure returns (uint128) {
        return TARGET_WALLET_BALANCE;
    }
    function _buildWalletInitData(address walletOwner) override internal view returns (TvmCell) {
        return tvm.buildStateInit({contr: TokenWallet, varInit: { root_: root_, owner_: walletOwner }, pubkey: 0, code: tvm.code()});
    }

    function _deployWallet(TvmCell initData, uint128 deployWalletValue, address) override internal view returns (address) {
        address wallet = new TokenWallet { stateInit: initData, value: deployWalletValue, wid: address(this).wid, flag: SENDER_PAYS_FEES }();
        return wallet;
    }
}
