pragma ever-solidity >= 0.62.0;

import "Token.sol";
abstract contract TokenRootBase is ITokenRoot, ICallbackParamsStructure {
    uint16 constant WRONG_ROOT_OWNER = 1020;
    uint16 constant MINT_DISABLED = 2100;
    uint16 constant BURN_DISABLED = 2200;
    uint16 constant BURN_BY_ROOT_DISABLED = 2210;
    uint128 constant TARGET_ROOT_BALANCE = 1 ton;
    string static name_;
    string static symbol_;
    uint8 static decimals_;
    address static rootOwner_;
    TvmCell static walletCode_;
    uint128 totalSupply_;
    fallback() external {
    }
    modifier onlyRootOwner() {
        require(rootOwner_.value != 0 && rootOwner_ == msg.sender, NOT_OWNER);
        _;
    }
    function name() override external view responsible returns (string) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } name_;
    }
    function symbol() override external view responsible returns (string) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } symbol_;
    }
    function decimals() override external view responsible returns (uint8) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } decimals_;
    }
    function totalSupply() override external view responsible returns (uint128) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } totalSupply_;
    }
    function walletCode() override external view responsible returns (TvmCell) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } walletCode_;
    }
    function rootOwner() override external view responsible returns (address) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } rootOwner_;
    }
    function walletOf(address walletOwner) override public view responsible returns (address) {
        require(walletOwner.value != 0, WRONG_WALLET_OWNER);
        return { value: 0, flag: REMAINING_GAS, bounce: false } _getExpectedWalletAddress(walletOwner);
    }
    function deployWallet(address walletOwner, uint128 deployWalletValue) public override responsible returns (address tokenWallet) {
        require(walletOwner.value != 0, WRONG_WALLET_OWNER);
        tvm.rawReserve(_reserve(), 0);
        tokenWallet = _deployWallet(_buildWalletInitData(walletOwner), deployWalletValue, msg.sender);
        return { value: 0, flag: ALL_NOT_RESERVED, bounce: false } tokenWallet;
    }
    function mint( uint128 amount, address recipient, uint128 deployWalletValue, address remainingGasTo, bool notify, TvmCell payload ) override external onlyRootOwner {
        require(_mintEnabled(), MINT_DISABLED);
        require(amount > 0, WRONG_AMOUNT);
        require(recipient.value != 0, WRONG_RECIPIENT);
        tvm.rawReserve(_reserve(), 0);
        _mint(amount, recipient, deployWalletValue, remainingGasTo, notify, payload);
    }
    function acceptBurn( uint128 amount, address walletOwner, address remainingGasTo, address callbackTo, TvmCell payload ) override external functionID(0x192B51B1) {
        require(_burnEnabled(), BURN_DISABLED);
        require(msg.sender == _getExpectedWalletAddress(walletOwner), SENDER_IS_NOT_VALID_WALLET);
        tvm.rawReserve(address(this).balance - msg.value, 2);
        totalSupply_ -= amount;
        if (callbackTo.value == 0)
            remainingGasTo.transfer({value: 0,flag: ALL_NOT_RESERVED + IGNORE_ERRORS,bounce: false});
        else
            IAcceptTokensBurnCallback(callbackTo).onAcceptTokensBurn{ value: 0, flag: ALL_NOT_RESERVED + IGNORE_ERRORS, bounce: false }( amount, walletOwner, msg.sender, remainingGasTo, payload );
    }
    function _mint( uint128 amount, address recipient, uint128 deployWalletValue, address remainingGasTo, bool notify, TvmCell payload ) internal {
        TvmCell stateInit = _buildWalletInitData(recipient);
        address recipientWallet;
        if (deployWalletValue > 0)
            recipientWallet = _deployWallet(stateInit, deployWalletValue, remainingGasTo);
        else
            recipientWallet = address(tvm.hash(stateInit));
        totalSupply_ += amount;
        ITokenWallet(recipientWallet).acceptMint{ value: 0, flag: ALL_NOT_RESERVED, bounce: true }( amount, remainingGasTo, notify, payload );
    }
    function _getExpectedWalletAddress(address walletOwner) internal view returns (address) {
        return address(tvm.hash(_buildWalletInitData(walletOwner)));
    }
    onBounce(TvmSlice slice) external {
        if (slice.loadUint(32) == tvm.functionId(ITokenWallet.acceptMint))
            totalSupply_ -= uint128(slice.loadUint(128));
    }
    function sendSurplusGas(address to) external view onlyRootOwner {
        tvm.rawReserve(_targetBalance(), 0);
        to.transfer({ value: 0, flag: ALL_NOT_RESERVED + IGNORE_ERRORS, bounce: false });
    }
    function _reserve() internal pure returns (uint128) {
        return math.max(address(this).balance - msg.value, _targetBalance());
    }
    function _targetBalance() virtual internal pure returns (uint128);
    function _mintEnabled() virtual internal view returns (bool);
    function _burnEnabled() virtual internal view returns (bool);
    function _buildWalletInitData(address walletOwner) virtual internal view returns (TvmCell);
    function _deployWallet(TvmCell initData, uint128 deployWalletValue, address remainingGasTo) virtual internal view returns (address);
}

abstract contract TokenRootBurnableByRootBase is TokenRootBase, IBurnableByRootTokenRoot {
    bool burnByRootDisabled_;
    function burnTokens(uint128 amount,address walletOwner,address remainingGasTo,address callbackTo,TvmCell payload) override external onlyRootOwner {
        require(!burnByRootDisabled_, BURN_BY_ROOT_DISABLED);
        require(amount > 0, WRONG_AMOUNT);
        require(walletOwner.value != 0, WRONG_WALLET_OWNER);
        IBurnableByRootTokenWallet(_getExpectedWalletAddress(walletOwner)).burnByRoot{value: 0,bounce: true,flag: REMAINING_GAS}(amount, remainingGasTo, callbackTo, payload );
    }
    function disableBurnByRoot() override external responsible onlyRootOwner returns (bool) {
        burnByRootDisabled_ = true;
        return { value: 0, flag: REMAINING_GAS, bounce: false } burnByRootDisabled_;
    }
    function burnByRootDisabled() override external view responsible returns (bool) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } burnByRootDisabled_;
    }
}

abstract contract TokenRootBurnPausableBase is TokenRootBase, IBurnPausableTokenRoot {
    bool burnPaused_;
    function burnPaused() override external view responsible returns (bool) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } burnPaused_;
    }
    function setBurnPaused(bool paused) override external responsible onlyRootOwner returns (bool) {
        burnPaused_ = paused;
        return { value: 0, flag: REMAINING_GAS, bounce: false } burnPaused_;
    }
    function _burnEnabled() override internal view returns (bool) {
        return !burnPaused_;
    }
}

abstract contract TokenRootDisableableMintBase is TokenRootBase, IDisableableMintTokenRoot {
    bool mintDisabled_;
    function disableMint() override external responsible onlyRootOwner returns (bool) {
        mintDisabled_ = true;
        return { value: 0, flag: REMAINING_GAS, bounce: false } mintDisabled_;
    }
    function mintDisabled() override external view responsible returns (bool) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } mintDisabled_;
    }
    function _mintEnabled() override internal view returns (bool) {
        return !mintDisabled_;
    }
}

abstract contract TokenRootTransferableOwnershipBase is TokenRootBase, ITransferableOwnership {

    function transferOwnership( address newOwner, address remainingGasTo, mapping(address => CallbackParams) callbacks ) override external onlyRootOwner {
        tvm.rawReserve(_reserve(), 0);
        address oldOwner = rootOwner_;
        rootOwner_ = newOwner;
        optional(TvmCell) callbackToGasOwner;
        for ((address dest, CallbackParams p) : callbacks) {
            if (dest.value != 0) {
                if (remainingGasTo != dest)
                    ITransferTokenRootOwnershipCallback(dest).onTransferTokenRootOwnership{value: p.value,flag: SENDER_PAYS_FEES,bounce: false}(oldOwner, rootOwner_, remainingGasTo, p.payload);
                else
                    callbackToGasOwner.set(p.payload);
            }
        }
        if (remainingGasTo.value != 0) {
            if (callbackToGasOwner.hasValue())
                ITransferTokenRootOwnershipCallback(remainingGasTo).onTransferTokenRootOwnership{value: 0,flag: ALL_NOT_RESERVED,bounce: false}(oldOwner, rootOwner_, remainingGasTo, callbackToGasOwner.get());
            else
                remainingGasTo.transfer({value: 0,flag: ALL_NOT_RESERVED + IGNORE_ERRORS,bounce: false});
        }
    }
}

contract TokenRoot is TokenRootTransferableOwnershipBase, TokenRootBurnPausableBase, TokenRootBurnableByRootBase, TokenRootDisableableMintBase {

    uint256 static randomNonce_;
    address static deployer_;

    constructor( address initialSupplyTo, uint128 initialSupply, uint128 deployWalletValue, bool mintDisabled, bool burnByRootDisabled, bool burnPaused, address remainingGasTo ) {
        if (msg.pubkey() != 0) {
            require(msg.pubkey() == tvm.pubkey() && deployer_.value == 0, WRONG_ROOT_OWNER);
            tvm.accept();
        } else
            require(deployer_.value != 0 && msg.sender == deployer_ || deployer_.value == 0 && msg.sender == rootOwner_, WRONG_ROOT_OWNER);
        totalSupply_ = 0;
        mintDisabled_ = mintDisabled;
        burnByRootDisabled_ = burnByRootDisabled;
        burnPaused_ = burnPaused;
        tvm.rawReserve(_targetBalance(), 0);
        if (initialSupplyTo.value != 0 && initialSupply != 0) {
            TvmCell empty;
            _mint(initialSupply, initialSupplyTo, deployWalletValue, remainingGasTo, false, empty);
        } else if (remainingGasTo.value != 0)
            remainingGasTo.transfer({ value: 0, flag: ALL_NOT_RESERVED + IGNORE_ERRORS, bounce: false});
    }
    function supportsInterface(bytes4 interfaceID) override external view responsible returns (bool) {
        return { value: 0, flag: REMAINING_GAS, bounce: false } (interfaceID == bytes4(0x3204ec29) || interfaceID == bytes4(0x4371d8ed) || interfaceID == bytes4(0x0b1fd263) || interfaceID == bytes4(0x18f7cce4) || interfaceID == bytes4(0x0095b2fa) || interfaceID == bytes4(0x45c92654) || interfaceID == bytes4(0x1df385c6));
    }

    function _targetBalance() override internal pure returns (uint128) {
        return TARGET_ROOT_BALANCE;
    }

    function _buildWalletInitData(address walletOwner) override internal view returns (TvmCell) {
        return tvm.buildStateInit({ contr: TokenWallet, varInit: { root_: address(this), owner_: walletOwner }, pubkey: 0, code: walletCode_ });
    }

    function _deployWallet(TvmCell initData, uint128 deployWalletValue, address) override internal view returns (address) {
        address tokenWallet = new TokenWallet { stateInit: initData, value: deployWalletValue, flag: SENDER_PAYS_FEES, code: walletCode_ }();
        return tokenWallet;
    }
}
