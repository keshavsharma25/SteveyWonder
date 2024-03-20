// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
		"M278.781 119.351C278.781 119.351 279.641 96.6221 276.503 95.4675C273.363 94.3137 272.378 96.9258 272.687 98.5668C269.239 99.6004 257.296 92.5502 257.296 92.5502C257.296 92.5502 258.342 96.1967 263.329 99.114C257.049 100.694 245.352 88.6617 245.352 88.6617C245.352 88.6617 245.413 94.5565 254.894 98.7495C244.982 98.8104 240.304 94.0093 240.304 94.0093C240.304 94.0093 240.919 95.4066 243.935 98.5067C233.594 96.4403 231.747 89.269 231.747 89.269C231.747 89.269 231.439 95.163 235.441 99.114C226.268 97.5332 220.481 78.9385 220.481 78.9385C220.481 78.9385 220.604 85.6834 223.067 88.6609C220.605 88.6 216.296 82.3406 216.296 82.3406C216.296 82.3406 217.403 86.838 219.99 89.7546C214.142 86.6553 212.724 80.7605 212.724 80.7605C212.724 80.7605 212.11 89.8147 206.814 92.672C208.909 89.0863 209.279 80.5169 209.279 80.5169C209.279 80.5169 207.492 87.6272 202.383 91.8202C204.414 87.8091 204.723 78.9377 204.723 78.9377C204.723 78.9377 191.98 91.3955 194.256 116.614C181.821 110.173 186.522 85.783 188.747 80.335C190.973 74.8862 191.453 64.1582 206.631 57.3038C227.625 47.8234 250.712 50.3548 262.53 56.2702C270.217 60.1191 276.696 70.3048 277.634 72.4363C280.013 77.8431 287.266 79.415 286.724 81.2469C284.815 87.6881 289.124 87.3236 287.709 92.3683C286.293 97.4122 287.278 99.175 287.586 102.639C287.893 106.103 284.26 114.549 278.781 119.351Z",
		"M287.5 91.3401C285.785 90.3286 283.849 85.3292 283.849 85.3292C283.849 85.3292 285.058 85.5719 286.504 84.8792C282.522 82.2954 282.136 76.2845 282.136 76.2845C282.136 76.2845 283.352 76.5648 284.181 76.791C282.909 73.6442 280.752 72.4081 280.752 72.4081C280.752 72.4081 282.964 73.2507 284.624 71.1727C282.356 70.7227 278.872 64.2626 272.677 61.1158C272.677 61.1158 275.055 60.3296 277.711 60.8911C276.825 59.5427 272.789 59.037 272.789 59.037C272.789 59.037 275.001 57.9139 276.77 57.6328C274.171 56.6221 270.687 57.3524 270.687 57.3524C270.687 57.3524 271.682 55.1056 274.337 53.5891C270.963 52.3773 267.701 52.6326 267.701 52.6326C267.701 52.6326 267.313 47.8585 263.608 45.3297C263.553 46.847 261.396 50.2734 261.396 50.2734C261.396 50.2734 260.567 45.3297 261.064 41.6779C258.797 43.0271 257.966 45.6667 257.966 45.6667C257.966 45.6667 255.921 41.3976 255.865 38.7007C253.984 39.6557 253.045 43.5879 253.045 43.5879C253.045 43.5879 251.44 39.8245 252.325 38.1392C248.73 39.8811 247.126 42.8583 247.126 42.8583C247.126 42.8583 247.126 38.1958 248.896 35.7801C245.798 37.7458 245.688 42.0722 245.688 42.0722C245.688 42.0722 244.968 37.9154 241.595 35.4432C243.199 38.2515 242.483 40.5266 242.483 40.5266C242.483 40.5266 239.199 34.0107 235.299 33C235.078 36.8481 230.014 40.5266 230.014 40.5266C230.014 40.5266 229.299 38.2515 230.903 35.4432C227.529 37.9154 226.81 42.0722 226.81 42.0722C226.81 42.0722 226.699 37.7458 223.602 35.7801C225.372 38.1958 225.372 42.8583 225.372 42.8583C225.372 42.8583 223.769 39.8811 220.173 38.1392C221.057 39.8253 219.454 43.5879 219.454 43.5879C219.454 43.5879 218.514 39.6557 216.633 38.7007C216.579 41.3976 214.531 45.6667 214.531 45.6667C214.531 45.6667 213.703 43.0271 211.434 41.6779C211.933 45.3297 211.103 50.2734 211.103 50.2734C211.103 50.2734 208.946 46.847 208.89 45.3297C205.185 47.8585 204.798 52.6326 204.798 52.6326C204.798 52.6326 201.536 52.3773 198.162 53.5891C200.817 55.1056 201.812 57.3524 201.812 57.3524C201.812 57.3524 198.327 56.6221 195.728 57.6328C197.498 57.9139 199.71 59.037 199.71 59.037C199.71 59.037 195.673 59.5435 194.788 60.8911C197.443 60.3296 199.821 61.1158 199.821 61.1158C193.626 64.2626 190.143 70.722 187.875 71.1727C189.534 73.2515 191.746 72.4081 191.746 72.4081C191.746 72.4081 189.59 73.6442 188.317 76.791C189.147 76.5656 190.364 76.2845 190.364 76.2845C190.364 76.2845 189.977 82.2954 185.996 84.8792C187.44 85.5719 188.651 85.3292 188.651 85.3292C188.651 85.3292 186.714 90.3286 185 91.3401C185.719 92.0139 187.378 91.1713 187.378 91.1713C187.378 91.1713 186.864 92.8982 187.141 97.1689C187.417 101.439 191.692 108.925 192.853 117.127C194.402 111.003 196.613 102.857 196.613 102.857C196.613 102.857 197.721 104.599 199.932 104.318C197.167 101.509 197.941 92.5197 197.941 92.5197C197.941 92.5197 199.545 97.8011 201.425 98.588C200.707 94.3173 201.812 90.7221 201.812 90.7221C201.812 90.7221 202.2 93.082 204.411 93.6435C203.416 91.9582 202.642 87.4645 202.642 87.4645C202.642 87.4645 203.938 89.2181 206.569 89.6556C202.697 82.6889 207.085 80.9289 212.099 79.4305C215.294 78.4756 222.736 86.636 234.68 89.4592C233.61 87.1818 233.32 85.2545 233.32 85.2545C233.32 85.2545 236.985 88.8585 243.236 89.4294C244.729 83.8677 255.455 77.9525 260.398 79.4305C265.413 80.9282 269.8 82.6889 265.929 89.6556C268.56 89.2181 269.855 87.4645 269.855 87.4645C269.855 87.4645 269.081 91.9582 268.085 93.6435C270.297 93.082 270.684 90.7221 270.684 90.7221C270.684 90.7221 271.791 94.3173 271.072 98.588C272.953 97.8011 274.556 92.5197 274.556 92.5197C274.556 92.5197 275.331 101.509 272.565 104.318C274.776 104.598 275.883 102.857 275.883 102.857C275.883 102.857 278.096 111.003 279.644 117.127C280.805 108.925 285.079 101.439 285.357 97.1689C285.633 92.8982 285.12 91.1713 285.12 91.1713C285.12 91.1713 286.781 92.0147 287.5 91.3401Z",
		"M294.5 71.8221C292.845 68.1615 286.244 63.9688 285.025 61.7478C287.059 61.8067 290.695 64.9575 290.695 64.9575C290.695 64.9575 286.566 58.4803 280.28 55.913C275.848 54.1028 263.703 41 236.372 41C231.349 41 223.36 42.8457 214.263 47.8609C214.368 44.3712 220.222 42.2379 220.222 42.2379C220.222 42.2379 212.491 41.408 209.098 49.0839C195.769 49.7028 193.997 55.2296 190.728 58.5914C187.458 61.9523 182.106 62.7374 178 71.823C181.272 68.9597 182.836 69.4536 182.836 69.4536C182.836 69.4536 177.9 91.3114 181.62 97.3657C185.339 103.423 191.877 129 193.102 129C194.326 129 191.641 93.7696 196.603 84.5953C200.253 77.8465 207.903 77.6149 221.252 80.5127C227.287 81.5864 233.244 81.7666 235.674 81.7927V81.7964C235.674 81.7964 235.889 81.8002 236.25 81.7983C236.611 81.8002 236.826 81.7964 236.826 81.7964V81.7927C239.255 81.7666 245.213 81.5864 251.248 80.5127C264.598 77.6158 272.247 77.8465 275.897 84.5953C280.859 93.7696 278.286 125.445 279.398 129C290.87 113.989 287.159 103.423 290.88 97.3657C294.6 91.3114 289.664 69.4536 289.664 69.4536C289.664 69.4536 291.228 68.9588 294.5 71.8221Z",
		"M282.661 79.4186C277.819 67.9252 266.064 53 236.5 53C206.936 53 195.179 67.9252 190.339 79.4186C185.497 90.9129 186.016 113.559 186.016 116.989C186.016 120.421 187.572 120.592 188.783 122.822C189.994 125.053 189.129 131.743 189.994 133.037C190.857 134.331 193.105 136.032 193.94 135.689C194.774 135.346 194.315 129.341 193.969 122.822C193.623 116.304 196.389 107.898 198.464 105.324C200.538 102.75 197.946 98.9755 197.081 96.4026C196.217 93.8297 199.675 81.6494 203.479 79.5914C207.282 77.5326 217.31 84.3951 236.5 84.3951C255.691 84.3951 265.718 77.5326 269.522 79.5914C273.326 81.6494 276.783 93.8297 275.919 96.4026C275.055 98.9764 272.461 102.751 274.536 105.324C276.61 107.898 279.376 116.304 279.031 122.822C278.686 129.341 278.225 135.346 279.06 135.689C279.895 136.032 282.142 134.331 283.007 133.037C283.872 131.743 283.007 125.053 284.217 122.822C285.428 120.592 286.983 120.421 286.983 116.989C286.984 113.558 287.502 90.9129 282.661 79.4186Z",
		"M277.585 122.25C282.298 98.6005 273.677 80.3015 267.393 79.4582C261.107 78.6159 257.833 92.0107 241.399 91.1478C245.923 89.4408 249.555 85.7135 249.555 85.7135C249.555 85.7135 240.162 87.2001 231.464 85.4609C221.266 83.4229 214.2 76.6795 208.504 79.3404C203.36 81.7426 200.44 85.3351 199.803 89.7575C198.703 88.8884 198.2 87.8819 198.2 87.8819C198.2 87.8819 191.076 98.9182 193.666 120.06C185.152 107.951 185.003 94.1478 185.003 94.1478C185.003 94.1478 183.814 93.9265 182 95.5827C183.464 56.097 219.295 45.2177 219.295 45.2177C219.295 45.2177 217.512 44.585 213.244 45.5336C217.894 42.248 243.53 43.9997 244.422 43.3679C245.314 42.7361 244.839 41.0478 241.592 40.4794C253.759 34.6034 263.297 48.1151 264.444 48.3043C265.589 48.4953 267.2 48.5675 267.519 45.091C271.278 49.3876 267.328 54.6309 267.328 54.6309C267.328 54.6309 273.826 51.2186 282.298 53.7457C274.144 54.9477 270.195 57.4105 270.195 57.4105C270.195 57.4105 291.598 54.8834 293 80.281C291.344 77.5014 290.325 77.1846 290.325 77.1846C290.325 77.1846 295.804 91.4619 277.585 122.25Z"
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
	) public view returns (string memory) {
		return
			string.concat(
				'<svg xmlns="http://www.w3.org/2000/svg"  width="400" height="400" viewBox="0 0 400 400" fill="none">',
				'<rect id="',
				Strings.toString(_tokenId),
				'" width="400" height="400" fill="black" fill-opacity="0.05"/>',
				'<g transform="translate(-272.5,7.5) scale(2, 2)">',
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
