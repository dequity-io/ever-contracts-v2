pragma ton-solidity >= 0.58.1;

uint128 constant REMAIN_ON_SELL = 0.14 ever;
uint128 constant DEPLOY_FEE = 0.19 ever;
uint128 constant UNIT_FEE = 0.28 ever;
uint128 constant SELL_FEE = 0.39 ever;
uint128 constant CALLBACK_FEE = 0.13 ever;

interface IUnitSell {
    event OfferReady(address unit, address seller, uint128 price);
    event OfferConfirmed(address unit, address seller, address buyer, uint128 price);
    event OfferCanceled(address unit, address seller, uint128 price);
    function onUnitSellTokenWalletDeploy(address tokenWallet) external;
    function onOwnerTokenWalletDeploy(address tokenWallet) external;
    function onGetUnitRoyalty(uint8 royalty, address royaltyReceiver) external;
    function cancelOffer() external;
    function getOfferInfo() external view responsible returns(address unit,address seller,address unitSellRoot,address tokenWallet,uint128 price);
    function getConfirmOfferGas() external view responsible returns(uint128);
    function getCancelOfferGas() external view responsible returns(uint128);
}
