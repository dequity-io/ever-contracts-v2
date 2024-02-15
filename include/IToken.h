pragma ever-solidity >= 0.72.0;

uint8 constant SENDER_PAYS_FEES = 1;
uint8 constant IGNORE_ERRORS = 2;
uint8 constant DESTROY_IF_ZERO = 32;
uint8 constant REMAINING_GAS = 64;
uint8 constant ALL_NOT_RESERVED = 128;

interface TIP3TokenRoot {
    function name() external view responsible returns (string);
    function symbol() external view responsible returns (string);
    function decimals() external view responsible returns (uint8);
    function totalSupply() external view responsible returns (uint128);
    function walletCode() external view responsible returns (TvmCell);
}

interface SID {
    function supportsInterface(bytes4 interfaceID) external view responsible returns (bool);
}

interface ITokenRoot is TIP3TokenRoot, SID {
    function rootOwner() external view responsible returns (address);
    function walletOf(address walletOwner) external view responsible returns (address);
    function acceptBurn(uint128 amount,address walletOwner,address remainingGasTo,address callbackTo,TvmCell payload) external functionID(0x192B51B1);
    function mint(uint128 amount,address recipient,uint128 deployWalletValue,address remainingGasTo,bool notify,TvmCell payload) external;
    function deployWallet(address owner,uint128 deployWalletValue) external responsible returns (address);
}

interface TIP3TokenWallet {
    function root() external view responsible returns (address);
    function balance() external view responsible returns (uint128);
    function walletCode() external view responsible returns (TvmCell);
}

interface ITokenWallet is TIP3TokenWallet, SID {
    function owner() external view responsible returns (address);
    function transfer(uint128 amount,address recipient,uint128 deployWalletValue,address remainingGasTo,bool notify,TvmCell payload) external;
    function transferToWallet(uint128 amount,address recipientTokenWallet,address remainingGasTo,bool notify,TvmCell payload) external;
    function acceptTransfer(uint128 amount,address sender,address remainingGasTo,bool notify,TvmCell payload) external functionID(0x67A0B95F);
    function acceptMint(uint128 amount,address remainingGasTo,bool notify,TvmCell payload) external functionID(0x4384F298);
}

interface IAcceptTokensTransferCallback {
    function onAcceptTokensTransfer( address tokenRoot, uint128 amount, address sender, address senderWallet, address remainingGasTo, TvmCell payload ) external;
}

interface IAcceptTokensBurnCallback {
    function onAcceptTokensBurn(uint128 amount,address walletOwner,address wallet,address remainingGasTo,TvmCell payload) external;
}

interface IAcceptTokensMintCallback {
    function onAcceptTokensMint(address tokenRoot,uint128 amount,address remainingGasTo,TvmCell payload) external;
}

interface IBounceTokensBurnCallback {
    function onBounceTokensBurn(address tokenRoot,uint128 amount) external;
}

interface IBounceTokensTransferCallback {
    function onBounceTokensTransfer( address tokenRoot, uint128 amount, address revertedFrom ) external;
}

interface IBurnableByRootTokenRoot {
    function burnTokens( uint128 amount, address walletOwner, address remainingGasTo, address callbackTo, TvmCell payload ) external;
    function disableBurnByRoot() external responsible returns (bool);
    function burnByRootDisabled() external view responsible returns (bool);
}

interface IBurnableByRootTokenWallet {
    function burnByRoot( uint128 amount, address remainingGasTo, address callbackTo, TvmCell payload ) external;
}

interface IBurnableTokenWallet {
    function burn(uint128 amount,address remainingGasTo,address callbackTo,TvmCell payload) external;
}

interface IBurnPausableTokenRoot {
    function setBurnPaused(bool paused) external responsible returns (bool);
    function burnPaused() external view responsible returns (bool);
}

interface IDestroyable {
    function destroy(address remainingGasTo) external;
}

interface IDisableableMintTokenRoot {
    function disableMint() external responsible returns (bool);
    function mintDisabled() external view responsible returns (bool);
}

interface ITokenRootUpgradeable is ITokenRoot {
    function walletVersion() external view responsible returns (uint32);
    function platformCode() external view responsible returns (TvmCell);
    function requestUpgradeWallet(uint32 currentVersion, address walletOwner, address remainingGasTo) external;
    function setWalletCode(TvmCell code) external;
    function upgrade(TvmCell code) external;
}

interface IVersioned {
    function version() external view responsible returns (uint32);
}

interface ITokenWalletUpgradeable is ITokenWallet, IVersioned {
    function platformCode() external view responsible returns (TvmCell);
    function upgrade(address remainingGasTo) external;
    function acceptUpgrade(TvmCell code, uint32 newVersion, address remainingGasTo) external;
}

interface ITransferTokenRootOwnershipCallback {
    function onTransferTokenRootOwnership(address oldOwner,address newOwner,address remainingGasTo,TvmCell payload) external;
}

interface ICallbackParamsStructure {
    struct CallbackParams {
        uint128 value;
        TvmCell payload;
    }
}

interface ITransferableOwnership is ICallbackParamsStructure {
    function transferOwnership(address newOwner,address remainingGasTo,mapping(address => CallbackParams) callbacks) external;
}
