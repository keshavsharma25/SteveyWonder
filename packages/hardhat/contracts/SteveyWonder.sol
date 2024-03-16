// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
import { IERC6551Registry } from "erc6551/interfaces/IERC6551Registry.sol";
import { IERC4906 } from "./interfaces/IERC4906.sol";
import { IERC721Custom } from "./interfaces/IERC721Custom.sol";
import { Background } from "./helpers/Background.sol";

/**
 * @title SteveyWonder
 * @author Keshav
 * @notice A simple ERC721 contract that mints Stevey NFTs that are converted to
 * ERC6551 tokens.
 * @dev This contract is designed to be used with the ERC6551Registry and Account Proxy contract.
 */
contract SteveyWonder is
	ERC721,
	ERC721Burnable,
	ERC721Enumerable,
	Ownable,
	IERC4906
{
	/* ----------------------------- State Variables ---------------------------- */
	address public immutable _erc6551Registry;
	address public immutable _accImplementation;
	Background public immutable _background;
	bytes32 public immutable salt = bytes32(0);

	uint256 private _nextTokenId = 1;
	uint256 private price;
	address[] public nftAccessoryAddrs;
	mapping(address => bool) public hasNftAccessoryAddrs;

	mapping(address => mapping(uint256 => uint256)) public activeAccessories;

	/* ------------------------------- Constructor ------------------------------ */
	constructor(
		address _initialOwner,
		address _erc6551RegistryAddr,
		address _accImplementationAddr,
		address _backgroundAddr
	) ERC721("Stevey", "STEV") Ownable(_initialOwner) {
		_erc6551Registry = _erc6551RegistryAddr;
		_accImplementation = _accImplementationAddr;
		_background = Background(_backgroundAddr);
	}

	/* -------------------------------- Functions ------------------------------- */
	function safeMint() public payable returns (address) {
		uint256 tokenId = _nextTokenId++;
		_safeMint(msg.sender, tokenId);

		address tba = IERC6551Registry(_erc6551Registry).createAccount(
			_accImplementation,
			bytes32(0),
			block.chainid,
			address(this),
			tokenId
		);

		return tba;
	}

	function contractURI() public pure returns (string memory) {
		string memory json = string.concat(
			'{"name": "SteveyWonder", "description": "This is a collection of SteveyWonder NFTs.", "image": "',
			'", "external_link": "https://steveywonder.vercel.app/",',
			'"collaborators": [""]'
			'"}'
		);

		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(bytes(json))
				)
			);
	}

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		require(tokenId < _nextTokenId, "Token ID does not exist");
		return _steveyWonderTokenURI(tokenId);
	}

	function _steveyWonderTokenURI(
		uint256 tokenId
	) internal view returns (string memory) {
		string memory svg = _generateBase64(tokenId);
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "SteveyWonder", "image": "',
								svg,
								'", "description": "SteveyWonder Character NFT',
								" based on the implementation of ERC6551 and its application.",
								' This NFT account contains other accessories as NFTs."}'
							)
						)
					)
				)
			);
	}

	function _generateBase64(
		uint256 _tokenId
	) internal view returns (string memory) {
		return Base64.encode(bytes(generateSVGwithBackground(_tokenId)));
	}

	function generateSVGwithBackground(
		uint256 _tokenId
	) public view returns (string memory) {
		return
			string.concat(
				'<svg width="472" height="472" viewBox="0 0 472 472" fill="none" xmlns="http://www.w3.org/2000/svg">',
				_addBackground(_tokenId),
				"</svg>"
			);
	}

	function generateSVGwithoutBackground(
		uint256 _tokenId
	) public view returns (string memory) {
		return
			string.concat(
				'<svg width="472" height="472" viewBox="0 0 472 472" fill="none" xmlns="http://www.w3.org/2000/svg">',
				renderByTokenId(_tokenId),
				"</svg>"
			);
	}

	function _addBackground(
		uint256 _tokenId
	) internal view returns (string memory) {
		return
			string.concat(
				_background.getHeadBackground(),
				renderByTokenId(_tokenId),
				_background.getTailBackground()
			);
	}

	function renderByTokenId(
		uint256 _tokenId
	) public view returns (string memory) {
		string memory render = SteveyWonderSvg();

		for (uint256 i = 0; i < nftAccessoryAddrs.length; i++) {
			if (activeAccessories[nftAccessoryAddrs[i]][_tokenId] > 0) {
				render = string.concat(
					render,
					renderAccessory(
						nftAccessoryAddrs[i],
						activeAccessories[nftAccessoryAddrs[i]][_tokenId]
					)
				);
			}
		}

		return render;
	}

	function renderAccessory(
		address nftAccessory,
		uint256 _tokenId
	) internal view returns (string memory) {
		return IERC721Custom(nftAccessory).renderByTokenId(_tokenId);
	}

	function SteveyWonderSvg() internal pure returns (string memory) {
		return
			string.concat(
				'<rect width="42.9268" height="128.682" transform="matrix(1 0 0 -1 249.121 427.671)" fill="#EFA78C"/>',
				'<path d="M180.438 427.671H223.364V298.989H180.438V427.671Z" fill="#EFA78C"/>',
				'<rect width="42.9268" height="139.23" transform="matrix(1 0 0 -1 298.486 293.716)" fill="#EFA78C"/>',
				'<rect width="42.9268" height="139.23" transform="matrix(1 0 0 -1 131.072 293.716)" fill="#EFA78C"/>',
				'<rect x="174" y="154.485" width="124.488" height="145.559" fill="#E89B7F"/>',
				'<rect x="193.316" y="78.5439" width="85.8544" height="75.9443" fill="#EFA78C"/>',
				'<rect x="207.268" y="95.4209" width="17.1712" height="16.8768" fill="white"/>',
				'<rect x="213.709" y="98.584" width="10.732" height="10.548" fill="black"/>'
				'<rect x="223.363" y="131.282" width="25.7567" height="10.548" fill="#BB7156"/>',
				'<rect x="248.047" y="95.4209" width="17.1712" height="16.8768" fill="white"/>',
				'<rect x="248.047" y="98.584" width="10.732" height="10.548" fill="black"/>',
				'<path d="M298.484 300.046H173.996V352.785H233.02V341.182H239.459V352.785H298.484V300.046Z" fill="white"/>'
			);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view override(IERC165, ERC721, ERC721Enumerable) returns (bool) {
		return super.supportsInterface(interfaceId);
	}

	function addNftAccessoryAddr(address _nftAccessory) public onlyOwner {
		if (!hasNftAccessoryAddrs[_nftAccessory]) {
			nftAccessoryAddrs.push(_nftAccessory);
			hasNftAccessoryAddrs[_nftAccessory] = true;
		}
	}

	function setActiveAccessories(
		address _nftAccessory,
		uint256 _SteveyWondertokenId,
		uint256 _accessoryTokenId
	) public {
		require(
			ownerOf(_SteveyWondertokenId) == msg.sender,
			"only token owner can set accessory"
		);
		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"Not a valid NFT Accessory Address"
		);

		IERC721 nftAccessory = IERC721(_nftAccessory);

		require(
			nftAccessory.ownerOf(_accessoryTokenId) ==
				getTBAAddress(_SteveyWondertokenId),
			"only accessories that belong to the Token Bound Account can be set."
		);

		activeAccessories[_nftAccessory][
			_SteveyWondertokenId
		] = _accessoryTokenId;
	}

	function setActiveAccessoriesOnUpdate(
		address _nftAccessory,
		uint256 _SteveyWondertokenId,
		uint256 _accessoryTokenId
	) public {
		require(
			_nftAccessory == msg.sender,
			"only nft accessory address can set accessory"
		);

		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"Not a valid NFT Accessory Address"
		);

		activeAccessories[_nftAccessory][
			_SteveyWondertokenId
		] = _accessoryTokenId;
	}

	function getActiveAccessory(
		address _nftAccessory,
		uint256 _SteveyWondertokenId
	) public view returns (uint256) {
		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"invalid NFT Accessory address"
		);
		return activeAccessories[_nftAccessory][_SteveyWondertokenId];
	}

	function _update(
		address to,
		uint256 tokenId,
		address auth
	) internal override(ERC721, ERC721Enumerable) returns (address) {
		return super._update(to, tokenId, auth);
	}

	function _increaseBalance(
		address account,
		uint128 value
	) internal override(ERC721, ERC721Enumerable) {
		super._increaseBalance(account, value);
	}

	function getTBAAddress(uint256 tokenId) public view returns (address) {
		return
			IERC6551Registry(_erc6551Registry).account(
				_accImplementation,
				salt,
				block.chainid,
				address(this),
				tokenId
			);
	}

	/* --------------------------------- receive -------------------------------- */
	receive() external payable {}
}
