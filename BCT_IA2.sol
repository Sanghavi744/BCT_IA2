// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

contract DecentralizedMarketplace {
    enum AssetType { Music, Ebooks, DesignFiles }

    struct Asset {
        address payable creator;
        address payable owner;
        string name;
        uint price; // Price in Wei (smallest unit of ETH)
        AssetType assetType;
        uint royaltyPercentage; // Royalty percentage for resale
    }

    Asset[] public listedAssets;
    mapping(uint => bool) public assetSold;

    event AssetAdded(uint indexed assetIndex, address indexed creator, string name, uint price, AssetType assetType, uint royaltyPercentage);
    event AssetPurchased(uint indexed assetIndex, address indexed buyer, uint price);
    event OwnershipTransferred(uint indexed assetIndex, address indexed previousOwner, address indexed newOwner);

    // ✅ Function to list a new digital asset
    function addAsset(string memory _name, uint _price, AssetType _assetType, uint _royaltyPercentage) public {
        require(_price > 0, "Price must be greater than 0");
        require(_royaltyPercentage <= 50, "Royalty cannot exceed 50%");

        listedAssets.push(Asset({
            creator: payable(msg.sender),
            owner: payable(msg.sender),
            name: _name,
            price: _price,
            assetType: _assetType,
            royaltyPercentage: _royaltyPercentage
        }));

        emit AssetAdded(listedAssets.length - 1, msg.sender, _name, _price, _assetType, _royaltyPercentage);
    }

    // ✅ Function to buy an asset
    function buyAsset(uint _assetIndex) public payable {
        require(_assetIndex < listedAssets.length, "Invalid asset index");
        require(!assetSold[_assetIndex], "Asset already sold");

        Asset storage asset = listedAssets[_assetIndex];
        require(msg.value >= asset.price, "Insufficient payment");

        uint royaltyAmount = (asset.price * asset.royaltyPercentage) / 100;
        uint sellerAmount = asset.price - royaltyAmount;

        asset.creator.transfer(royaltyAmount); // Pay royalty to the original creator
        asset.owner.transfer(sellerAmount); // Pay the seller

        address previousOwner = asset.owner;
        asset.owner = payable(msg.sender); // Transfer ownership
        assetSold[_assetIndex] = true;

        emit AssetPurchased(_assetIndex, msg.sender, asset.price);
        emit OwnershipTransferred(_assetIndex, previousOwner, msg.sender);
    }

    // ✅ Get asset details
    function getAssetDetails(uint _assetIndex) public view returns (address, address, string memory, uint, AssetType, uint) {
        require(_assetIndex < listedAssets.length, "Invalid asset index");
        Asset storage asset = listedAssets[_assetIndex];
        return (asset.creator, asset.owner, asset.name, asset.price, asset.assetType, asset.royaltyPercentage);
    }

    // ✅ Get the total number of assets
    function getAssetCount() public view returns (uint) {
        return listedAssets.length;
    }
}
