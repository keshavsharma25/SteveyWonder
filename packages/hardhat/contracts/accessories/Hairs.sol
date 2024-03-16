// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IERC6551Registry } from "erc6551/interfaces/IERC6551Registry.sol";
import { IERC6551Account } from "erc6551/interfaces/IERC6551Account.sol";
import { ERC6551AccountLib } from "erc6551/lib/ERC6551AccountLib.sol";
import { SteveyWonder } from "../SteveyWonder.sol";

contract Hairs is ERC721, ERC721Burnable, Ownable, ERC721Enumerable {
	uint256 private _nextTokenId = 1;
	string[6] private colors = [
		"#FFFFFF",
		"#000000",
		"#C6444C",
		"#F6C745",
		"#5C4BF0",
		"#F04BC2"
	];

	string[5] private styles = [
		"M239.96 92.0907C239.96 92.0907 240.766 71.4439 237.825 70.395C234.881 69.3469 233.959 71.7198 234.248 73.2104C231.016 74.1494 219.823 67.7448 219.823 67.7448C219.823 67.7448 220.803 71.0574 225.477 73.7076C219.591 75.1429 208.628 64.2125 208.628 64.2125C208.628 64.2125 208.685 69.5675 217.571 73.3764C208.282 73.4317 203.896 69.0703 203.896 69.0703C203.896 69.0703 204.473 70.3397 207.3 73.1559C197.608 71.2787 195.876 64.7642 195.876 64.7642C195.876 64.7642 195.588 70.1184 199.339 73.7076C190.741 72.2715 185.318 55.3798 185.318 55.3798C185.318 55.3798 185.433 61.507 187.741 64.2117C185.434 64.1564 181.395 58.4703 181.395 58.4703C181.395 58.4703 182.433 62.5558 184.857 65.2053C179.376 62.3899 178.048 57.0349 178.048 57.0349C178.048 57.0349 177.472 65.2599 172.508 67.8555C174.471 64.5983 174.818 56.8136 174.818 56.8136C174.818 56.8136 173.144 63.2728 168.355 67.0817C170.259 63.438 170.549 55.379 170.549 55.379C170.549 55.379 158.604 66.696 160.738 89.605C149.083 83.7536 153.49 61.5974 155.575 56.6484C157.661 51.6986 158.111 41.9531 172.336 35.7265C192.013 27.1143 213.652 29.4139 224.728 34.7875C231.932 38.284 238.005 47.5368 238.884 49.4731C241.114 54.3847 247.912 55.8126 247.404 57.4767C245.615 63.3281 249.653 62.9969 248.327 67.5796C247 72.1616 247.923 73.7629 248.212 76.9095C248.499 80.0561 245.095 87.7293 239.96 92.0907Z",
		"M248 68.6405C246.394 67.6931 244.58 63.0107 244.58 63.0107C244.58 63.0107 245.713 63.238 247.067 62.5893C243.338 60.1694 242.976 54.5396 242.976 54.5396C242.976 54.5396 244.115 54.8022 244.892 55.014C243.7 52.0667 241.68 50.909 241.68 50.909C241.68 50.909 243.751 51.6983 245.306 49.752C243.182 49.3306 239.919 43.2801 234.117 40.3328C234.117 40.3328 236.344 39.5965 238.832 40.1224C238.002 38.8595 234.222 38.3858 234.222 38.3858C234.222 38.3858 236.293 37.334 237.951 37.0707C235.516 36.1241 232.253 36.8081 232.253 36.8081C232.253 36.8081 233.185 34.7038 235.672 33.2834C232.511 32.1485 229.457 32.3876 229.457 32.3876C229.457 32.3876 229.093 27.9163 225.623 25.5478C225.572 26.9689 223.552 30.178 223.552 30.178C223.552 30.178 222.775 25.5479 223.24 22.1276C221.117 23.3913 220.339 25.8634 220.339 25.8634C220.339 25.8634 218.423 21.865 218.371 19.3392C216.609 20.2336 215.73 23.9164 215.73 23.9164C215.73 23.9164 214.226 20.3918 215.056 18.8133C211.689 20.4447 210.186 23.2331 210.186 23.2331C210.186 23.2331 210.186 18.8663 211.844 16.6038C208.943 18.4448 208.839 22.4969 208.839 22.4969C208.839 22.4969 208.165 18.6037 205.006 16.2882C206.509 18.9185 205.838 21.0493 205.838 21.0493C205.838 21.0493 202.762 14.9466 199.109 14C198.902 17.6041 194.16 21.0493 194.16 21.0493C194.16 21.0493 193.49 18.9185 194.992 16.2882C191.832 18.6037 191.158 22.4969 191.158 22.4969C191.158 22.4969 191.055 18.4448 188.154 16.6038C189.812 18.8663 189.812 23.2331 189.812 23.2331C189.812 23.2331 188.311 20.4447 184.943 18.8133C185.771 20.3925 184.269 23.9164 184.269 23.9164C184.269 23.9164 183.388 20.2336 181.627 19.3392C181.576 21.865 179.659 25.8634 179.659 25.8634C179.659 25.8634 178.883 23.3913 176.758 22.1276C177.225 25.5479 176.447 30.178 176.447 30.178C176.447 30.178 174.427 26.9689 174.375 25.5478C170.905 27.9163 170.543 32.3876 170.543 32.3876C170.543 32.3876 167.487 32.1485 164.327 33.2834C166.814 34.7038 167.746 36.8081 167.746 36.8081C167.746 36.8081 164.482 36.1241 162.048 37.0707C163.705 37.334 165.777 38.3858 165.777 38.3858C165.777 38.3858 161.996 38.8603 161.167 40.1224C163.654 39.5965 165.881 40.3328 165.881 40.3328C160.079 43.2801 156.817 49.3298 154.693 49.752C156.247 51.699 158.318 50.909 158.318 50.909C158.318 50.909 156.299 52.0667 155.107 55.014C155.884 54.8029 157.024 54.5396 157.024 54.5396C157.024 54.5396 156.662 60.1694 152.933 62.5893C154.285 63.238 155.419 63.0107 155.419 63.0107C155.419 63.0107 153.605 67.6931 152 68.6405C152.673 69.2716 154.227 68.4823 154.227 68.4823C154.227 68.4823 153.746 70.0998 154.005 74.0996C154.264 78.0987 158.268 85.1098 159.355 92.7925C160.805 87.0568 162.877 79.4271 162.877 79.4271C162.877 79.4271 163.914 81.0585 165.985 80.7952C163.395 78.1642 164.12 69.7453 164.12 69.7453C164.12 69.7453 165.623 74.6917 167.384 75.4287C166.711 71.4289 167.746 68.0616 167.746 68.0616C167.746 68.0616 168.109 70.2719 170.18 70.7978C169.248 69.2194 168.523 65.0107 168.523 65.0107C168.523 65.0107 169.737 66.6531 172.201 67.0628C168.575 60.5379 172.684 58.8895 177.38 57.4861C180.373 56.5917 187.343 64.2346 198.529 66.8789C197.527 64.7458 197.256 62.9408 197.256 62.9408C197.256 62.9408 200.689 66.3162 206.543 66.851C207.941 61.6419 217.987 56.1019 222.616 57.4861C227.313 58.8888 231.422 60.5379 227.797 67.0628C230.261 66.6531 231.474 65.0107 231.474 65.0107C231.474 65.0107 230.749 69.2194 229.816 70.7978C231.888 70.2719 232.251 68.0616 232.251 68.0616C232.251 68.0616 233.287 71.4289 232.614 75.4287C234.375 74.6917 235.877 69.7453 235.877 69.7453C235.877 69.7453 236.602 78.1642 234.012 80.7952C236.083 81.0578 237.12 79.4271 237.12 79.4271C237.12 79.4271 239.192 87.0568 240.642 92.7925C241.73 85.1098 245.733 78.0987 245.993 74.0996C246.251 70.0998 245.771 68.4823 245.771 68.4823C245.771 68.4823 247.327 69.2723 248 68.6405Z",
		"M254 49.8221C252.466 46.1615 246.346 41.9688 245.217 39.7478C247.101 39.8067 250.473 42.9575 250.473 42.9575C250.473 42.9575 246.644 36.4803 240.817 33.913C236.709 32.1028 225.45 19 200.113 19C195.456 19 188.05 20.8457 179.617 25.8609C179.715 22.3712 185.142 20.2379 185.142 20.2379C185.142 20.2379 177.974 19.408 174.829 27.0839C162.473 27.7028 160.83 33.2296 157.799 36.5914C154.768 39.9523 149.806 40.7374 146 49.823C149.033 46.9597 150.484 47.4536 150.484 47.4536C150.484 47.4536 145.908 69.3114 149.356 75.3657C152.803 81.4228 158.865 107 160 107C161.135 107 158.645 71.7696 163.246 62.5953C166.63 55.8465 173.721 55.6149 186.096 58.5127C191.691 59.5864 197.213 59.7666 199.466 59.7927V59.7964C199.466 59.7964 199.665 59.8002 200 59.7983C200.335 59.8002 200.534 59.7964 200.534 59.7964V59.7927C202.786 59.7666 208.309 59.5864 213.904 58.5127C226.28 55.6158 233.37 55.8465 236.754 62.5953C241.355 71.7696 238.969 103.445 240 107C250.635 91.989 247.195 81.4228 250.644 75.3657C254.092 69.3114 249.516 47.4536 249.516 47.4536C249.516 47.4536 250.967 46.9588 254 49.8221Z",
		"M242.962 57.5876C238.456 46.8907 227.515 33 200 33C172.485 33 161.543 46.8907 157.038 57.5876C152.532 68.2853 153.015 89.3615 153.015 92.5545C153.015 95.7484 154.463 95.9076 155.59 97.9829C156.717 100.059 155.912 106.285 156.717 107.49C157.521 108.694 159.613 110.278 160.39 109.958C161.166 109.639 160.738 104.05 160.417 97.9829C160.095 91.9169 162.669 84.0931 164.601 81.6976C166.531 79.3022 164.118 75.7891 163.313 73.3945C162.509 70.9999 165.727 59.6638 169.267 57.7485C172.807 55.8323 182.14 62.2192 200 62.2192C217.861 62.2192 227.193 55.8323 230.733 57.7485C234.274 59.6638 237.491 70.9999 236.687 73.3945C235.883 75.7899 233.469 79.3031 235.4 81.6976C237.33 84.0931 239.905 91.9169 239.583 97.9829C239.262 104.05 238.833 109.639 239.61 109.958C240.388 110.278 242.479 108.694 243.284 107.49C244.088 106.285 243.284 100.059 244.41 97.9829C245.537 95.9076 246.985 95.7484 246.985 92.5545C246.985 89.3606 247.468 68.2853 242.962 57.5876Z",
		"M238.696 97.25C243.069 75.305 235.07 58.3248 229.238 57.5423C223.405 56.7607 220.368 69.1901 205.118 68.3894C209.316 66.8054 212.686 63.3468 212.686 63.3468C212.686 63.3468 203.97 64.7262 195.899 63.1124C186.436 61.2212 179.879 54.9639 174.594 57.433C169.82 59.662 167.111 62.9957 166.52 67.0993C165.499 66.2928 165.033 65.3588 165.033 65.3588C165.033 65.3588 158.422 75.5998 160.826 95.218C152.925 83.9818 152.787 71.1732 152.787 71.1732C152.787 71.1732 151.683 70.9678 150 72.5046C151.358 35.8648 184.607 25.7696 184.607 25.7696C184.607 25.7696 182.953 25.1825 178.993 26.0627C183.307 23.0139 207.095 24.6393 207.923 24.0531C208.751 23.4669 208.31 21.9002 205.297 21.3728C216.587 15.9203 225.438 28.4582 226.502 28.6337C227.565 28.8109 229.059 28.878 229.355 25.652C232.843 29.6389 229.178 34.5044 229.178 34.5044C229.178 34.5044 235.208 31.338 243.069 33.683C235.503 34.7983 231.839 37.0836 231.839 37.0836C231.839 37.0836 251.699 34.7387 253 58.3058C251.464 55.7265 250.518 55.4326 250.518 55.4326C250.518 55.4326 255.602 68.6809 238.696 97.25Z"
	];

	address private _steveyWonderAddr;
	address private _erc6551RegistryAddr;
	address private _accImplementationAddr;
	bytes32 private immutable _salt = bytes32(0);

	struct HairType {
		uint256 colorIndex;
		uint256 styleIndex;
	}

	mapping(uint256 => HairType) private _hairType;

	constructor(
		address _initialOwner,
		address _steveyWonder,
		address _erc6551Registry,
		address _accImplementation
	) ERC721("Hair", "HAIR") Ownable(_initialOwner) {
		_steveyWonderAddr = _steveyWonder;
		_erc6551RegistryAddr = _erc6551Registry;
		_accImplementationAddr = _accImplementation;
	}

	function safeMint(uint256 _toTokenId) public payable {
		uint256 tokenId = _nextTokenId++;

		address to = IERC6551Registry(_erc6551RegistryAddr).account(
			_accImplementationAddr,
			_salt,
			block.chainid,
			_steveyWonderAddr,
			_toTokenId
		);

		_safeMint(to, tokenId);

		bytes32 predictableRandom = keccak256(
			abi.encodePacked(
				tokenId,
				blockhash(block.number - 1),
				block.timestamp,
				msg.sender,
				address(this)
			)
		);

		uint256 index1 = uint256(uint8(predictableRandom[0])) % colors.length;
		uint256 index2 = uint256(uint8(predictableRandom[1])) % styles.length;

		_hairType[tokenId].colorIndex = index1;
		_hairType[tokenId].styleIndex = index2;
	}

	function _hairURI(uint256 _tokenId) internal view returns (string memory) {
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "SteveyWonder Hair #',
								Strings.toString(_tokenId),
								'", "image": "',
								_generateBase64(_tokenId),
								'", "description": "This is an Inventory NFT item that can be traded or bought to make your SteveyWonder look awesome!",',
								'"attributes": [{"trait_type": "type", "value": "hair"}, {"trait_type": "color", "value": "',
								colors[_hairType[_tokenId].colorIndex],
								'"}, {"trait_type": "style", "value": "',
								Strings.toString(
									_hairType[_tokenId].styleIndex
								),
								'"}]}'
							)
						)
					)
				)
			);
	}

	function _generateBase64(
		uint256 _tokenId
	) internal view returns (string memory) {
		return Base64.encode(bytes(_generateSVG(_tokenId)));
	}

	function _generateSVG(
		uint256 _tokenId
	) internal view returns (string memory) {
		return
			string.concat(
				'<svg xmlns="http://www.w3.org/2000/svg"  width="400" height="400" viewBox="0 0 400 400" fill="none">',
				'<rect id="',
				Strings.toString(_tokenId),
				'" width="400" height="400" fill="',
				colors[_hairType[_tokenId].colorIndex],
				'" fill-opacity="0.1"/>',
				'<g transform="translate(-200,60) scale(2, 2)">',
				renderByTokenId(_tokenId),
				"</g>",
				"</svg>"
			);
	}

	function renderByTokenId(
		uint256 _tokenId
	) public view returns (string memory) {
		return _hairSVG(_tokenId);
	}

	function _hairSVG(uint256 _tokenId) internal view returns (string memory) {
		return
			string.concat(
				'<path d="',
				styles[_hairType[_tokenId].styleIndex],
				'" fill="',
				colors[_hairType[_tokenId].colorIndex],
				'" />'
			);
	}

	function contractURI() public pure returns (string memory) {
		string memory json = string.concat(
			'{"name": "SteveyWonder Hair Collection", "description": "This is a collection of SteveyWonder\'s Hair NFTs.", "image": "',
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

	/* --------------------------- override functions --------------------------- */

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		return _hairURI(tokenId);
	}

	function _update(
		address to,
		uint256 tokenId,
		address auth
	) internal override(ERC721, ERC721Enumerable) returns (address) {
		address previousOwner = super._update(to, tokenId, auth);

		bool isErc6551Acc = ERC6551AccountLib.isERC6551Account(
			previousOwner,
			_accImplementationAddr,
			_erc6551RegistryAddr
		);

		if (isErc6551Acc) {
			(, , uint256 steveyWonderTokenId) = IERC6551Account(
				payable(previousOwner)
			).token();

			SteveyWonder steveyWonder = SteveyWonder(
				payable(_steveyWonderAddr)
			);

			if (
				tokenId ==
				steveyWonder.getActiveAccessory(
					address(this),
					steveyWonderTokenId
				)
			) {
				if (balanceOf(previousOwner) > 0) {
					steveyWonder.setActiveAccessories(
						address(this),
						steveyWonderTokenId,
						tokenOfOwnerByIndex(previousOwner, 0)
					);
				} else {
					steveyWonder.setActiveAccessories(
						address(this),
						steveyWonderTokenId,
						0
					);
				}
			}
		}
		return previousOwner;
	}

	function _increaseBalance(
		address account,
		uint128 value
	) internal override(ERC721, ERC721Enumerable) {
		super._increaseBalance(account, value);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view override(ERC721, ERC721Enumerable) returns (bool) {
		return super.supportsInterface(interfaceId);
	}
}
