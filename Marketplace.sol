// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

contract Marketplace {
    enum AssetType { Music, Ebooks, DesignFiles }

    struct Asset {
        address owner;
        string name;
        uint price;
        AssetType assetType;
    }

    Asset[] public listedAssets;

    event AssetAdded(uint indexed assetIndex, address indexed owner, string name, uint price, AssetType assetType);
    event OwnershipTransferred(uint indexed assetIndex, address indexed previousOwner, address indexed newOwner);

    function addAsset(string memory _name, uint _price, AssetType _assetType) public {
        require(_price > 0, "Price must be greater than 0");

        listedAssets.push(Asset({
            owner: msg.sender,
            name: _name,
            price: _price,
            assetType: _assetType
        }));

        emit AssetAdded(listedAssets.length - 1, msg.sender, _name, _price, _assetType);
    }

    function getAssetCount() public view returns (uint) {
        return listedAssets.length;
    }

    function getAssetDetails(uint _assetIndex) public view returns (address, string memory, uint, AssetType) {
        require(_assetIndex < listedAssets.length, "Invalid asset index");
        Asset storage asset = listedAssets[_assetIndex];
        return (asset.owner, asset.name, asset.price, asset.assetType);
    }

    function getAssetOwner(uint _assetIndex) public view returns (address) {
        require(_assetIndex < listedAssets.length, "Invalid asset index");
        return listedAssets[_assetIndex].owner;
    }

    function transferOwnership(uint _assetIndex, address _newOwner) public {
        require(_assetIndex < listedAssets.length, "Invalid asset index");
        require(_newOwner != address(0), "New owner cannot be zero address");

        Asset storage asset = listedAssets[_assetIndex];
        require(msg.sender == asset.owner, "Only the asset owner can transfer ownership");

        address previousOwner = asset.owner;
        asset.owner = _newOwner;

        emit OwnershipTransferred(_assetIndex, previousOwner, _newOwner);
    }
}
