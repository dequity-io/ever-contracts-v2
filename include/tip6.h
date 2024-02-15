pragma ton-solidity >= 0.72.0;

interface ITIP6 {
    function supportsInterface(bytes4 interfaceID) external view responsible returns (bool);
}
abstract contract TIP6 is ITIP6 {
    mapping(bytes4 => bool) internal _supportedInterfaces;
    function supportsInterface(bytes4 interfaceID) external override view responsible returns (bool) {
        return {value: 0, flag: 64, bounce: false} _supportedInterfaces[interfaceID];
    }
}
