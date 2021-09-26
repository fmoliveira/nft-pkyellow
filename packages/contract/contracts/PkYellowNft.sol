// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./libraries/Base64.sol";

contract PkYellowNft is ERC721URIStorage {
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	mapping(address => uint256) private _mintPerAddress;
	uint256 public MAX_PER_ADDRESS = 2;
	uint256 public MAX_MINT = 100;
	uint256 public publicIssued = 0;

	string baseSvg =
		'<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: black; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="white" stroke="';
	string moreSvg =
		'" stroke-width="30" /><text x="50%" y="75%" class="base" dominant-baseline="middle" text-anchor="middle">';
	string imageSvg = '</text><image href=" ';
	string endSvg =
		'" height="100" width="100" transform="translate(125,125)"/></svg>';

	string[] starters = [
		"Bulbasaur",
		"Charmander",
		"Squirtle",
		"Pikachu",
		"Eevee"
	];

	string[] colors = ["#9BCC50", "#FD7D24", "#30A7D7", "#EED535", "#A4ACAF"];

	string[] descriptions = [
		"There is a plant seed on its back right from the day this Pokemon is born. The seed slowly grows larger.",
		"It has a preference for hot things. When it rains, steam is said to spout from the tip of its tail.",
		"When it retracts its long neck into its shell, it squirts out water with vigorous force.",
		"Pikachu that can generate powerful electricity have cheek sacs that are extra soft and super stretchy.",
		"It has the ability to alter the composition of its body to suit its surrounding environment."
	];

	string[] images = [
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEWM/1r///8ZGRkItTG7XGWLAAABLUlEQVQYlWMIhQMGCphRW+HM/NUwZlj//qlQ5gv7/U8hzLjF//f/gjCT+/+t/30VzPz3/9X6V0/BzL5Vq1avWgliVu0WDQ14dR/ETOF1YGCQdAIxCw4w8DMw8IGY8TwG9gceWF8FMiOabezPdfyeCmRG6Zzht5bQBzHj6hkO6EvYg5hFZQwM22/wg5gp/wQY/p/gBpvLoMTAwMAFZlodeLWawQ5sxftX/18d0AGZG7f8//9vawxA2mrW////a0PDViBzE9+qVasOMfwEMh+sARrwhuFkKEOYAvOqVesZjA+BmB+s//+wZ/oEZP74w/f/zX+mf0C1O2z4/j/4ww/Sto4ByGSwfglkZjVorlrD8GopkDnz1a3QsnNpINuqlr0NjUtbCw6SSGB4zUQNdQAmya3Mqj7AMgAAAABJRU5ErkJggg==",
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEX/AAD///8ZGRn/jACzVFtxAAABT0lEQVQYlTXQv0vDUBAH8COg+APJlMWlVQmULk6dLM0qLi1pLhGq2M1FdPAPKAjOwSE4SumiXdo/QDBVinUondxdAm6+xqWFZ897j/SGx4fjy+PuAPGojboAPUdGGWvkJBkb8m2esUq2ZJwyi2F7wbxG8MtUUN0YoU40IkuzsfFIxL/Fn1Dbfgo1LfC63Q4HAmEBFvIFGuKZKAHu/bxS4ubECrj7FFMSPogxVHu0Ofk2cr8DuNz564UTcU8DqMdpxaRFQFPwRGeUI6Hoy2IpoHWkMWB/CwNpY5P/bdqIIsJnntflsdLocKHW5Flo1Zkykdn6MueKHGjNzOGyOzOTLNuaORGzPkSUUNF34NtQOlW8GjDlraLzgYHeGfAlRo+kpmNYJxRrXkAvFWAprhnuTdlQRz2WBvqO5nnfQC/NK7rdNvrvBzqryr6LlnR3+fkHj6G+GzUv8NsAAAAASUVORK5CYII=",
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEWE1v8AjP////8ZGRnaHr/WAAABNklEQVQYlWNYBQcMRDCX/78FY15g4IUyVzMwMLyCMNcAmVIQ5hIg0wrC7GRgvCAGYc5mYPsiB2FuZ+D7EwdhzmfgvQNlujKw58ZngZirDzAwfv8DMo1hS4kLA4+NLYg5wZihVkRmKlAFwxreuwwFLK1AqxmWsF5gPOi8FCS6kvH4/4OOilEgE5gbGAwYsn+BzD28gIGX4SFIdNXWVQ3sDqlhIOa6+v+3w3XjwMzVq1bVtoKZ61evWs0zFcxc9nLVur6tdSDmyl1Zu9qmX5ufBfQxMBwYeaMOWAFFXzgt/364moEP6GMDAW3WC28Y2IDhIGvAwlggwMAOZLJ+kWGoD5BhBSpgrP/DUBriCFS7kjFuDUNs6AUxUJhVrWGIqw+tAor+z1rCELcKZAUQrHasgkfAXLS4AAC0H82Ltq/DpwAAAABJRU5ErkJggg==",
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEXmcwD///8ZGRn//wBBN5LbAAABHElEQVQYGQXBIWtWURgA4LcsmCw7wbhgULC5HzDcHSoYPu95zt29n+AVOQMnKtq0DIRF49EsKzKzNqPgH7j7AcK6BsEi83niFoC4mwBi+ggQ998CRGkN8mmK3CryyZsUtvdfnd488UP4NiS9YUt4scDRsbDextFfQl7QHxMKFHLIE1NmCv1Bc/AheR7Gw+awNV/DamKSylnYTSXZ6dYlzBuI+qyEeWNzU9QvJeymR3fs7C0ljOCzEnoYbsghQ+6sQu/hP8MVNYyGP7zXwqhpUqthlZKU9tTQtS5rT6RQz2spy+MzoX6vJS9Pfwv1dZfX5nOhPmjemS8JHZivCivwswkjuEYoMDSCNlwsBcG9X3H5JYK25XZBcD3Jn/AfjxeR4e+jK5MAAAAASUVORK5CYII=",
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEVaWin///8ZGRmlvVJYS6nPAAABW0lEQVQYlUXRsUtCcRAH8OuBoC0O8abaTAjbao1ni0PgkvrVzMLKbK2lLVIMmwKnH0FLVgjyoKWtSTMEy6GpPyBECBoUQyh4dt3TyN/04fjC3e+O8P/IO+b9H9YVGfpQkTNFqbchPV1FQcPWmnUNSrjtRMGXA4U9SpI90wWKftSBhK/sBUUa7VMVNIsKhLuvz6cFMyctsPTC1nPZFRDuM/MPlbaFIWa/NYldYaRjtXq32BNGp3imBwSUcJovhCoggXk2a4CeJoQ9PFdDFFJNcOGxihRWpcoWT6DyGpesddN1RdlmyM1kJLj/TQhsEV2eMAv1A/Mq2RlStbkfEz4QzvXMINZirhP8CoNYk9lLCG7iKOlkdhB2DnG8kWNZCQwHeoZmkU6ozGYaRY2cMnqlyVlNo7xw8b2c9dGV/flUKV4tZZXNkB5f/iOwouVz+ohpTZ/DiKHi6CzjY/0C4V+40iEcu6wAAAAASUVORK5CYII="
	];

	event NewMint(address indexed from, uint256 tokenId);

	constructor() ERC721("PkYellowNft", "PKYELLOW") {}

	function mintPokemon() public {
		require(
			_mintPerAddress[msg.sender] < MAX_PER_ADDRESS,
			"You have reached your minting limit."
		);
		require(publicIssued < MAX_MINT, "There are no more NFTs for minting.");

		uint256 newItemId = _tokenIds.current();

		uint256 starterIndex = pickStarterPokemon(newItemId);

		string memory svg = string(
			abi.encodePacked(
				baseSvg,
				colors[starterIndex],
				moreSvg,
				starters[starterIndex],
				imageSvg,
				images[starterIndex],
				endSvg
			)
		);

		string memory json = Base64.encode(
			bytes(
				string(
					abi.encodePacked(
						'{"name": "',
						starters[starterIndex],
						'", "description": "',
						descriptions[starterIndex],
						'", "image": "data:image/svg+xml;base64,',
						// We add data:image/svg+xml;base64 and then append our base64 encode our svg.
						Base64.encode(bytes(svg)),
						'"}'
					)
				)
			)
		);

		string memory tokenUri = string(
			abi.encodePacked("data:application/json;base64,", json)
		);

		_mintPerAddress[msg.sender] += 1;
		publicIssued += 1;

		_safeMint(msg.sender, newItemId);
		_setTokenURI(newItemId, tokenUri);
		_tokenIds.increment();

		emit NewMint(msg.sender, newItemId);
	}

	function random(string memory input) internal pure returns (uint256) {
		return uint256(keccak256(abi.encodePacked(input)));
	}

	function pickStarterPokemon(uint256 tokenId)
		private
		view
		returns (uint256)
	{
		uint256 rand = random(
			string(
				abi.encodePacked(
					"STARTER",
					msg.sender,
					Strings.toString(tokenId)
				)
			)
		);
		return rand % starters.length;
	}
}
