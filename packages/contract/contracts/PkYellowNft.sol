// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import "./libraries/Base64.sol";

contract PkYellowNft is ERC721URIStorage {
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	mapping(address => uint256) private _mintPerAddress;
	uint256 public MAX_PER_ADDRESS = 2;
	uint256 public MAX_MINT = 250;

	string baseSvg =
		'<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { font-size: 20px; font-weight: bold; text-transform: uppercase; }</style><rect width="100%" height="100%" fill="white" stroke="';
	string moreSvg =
		'" stroke-width="30" /><text x="50%" y="70%" class="base" text-anchor="middle">';
	string levelSvg =
		'</text><text x="50%" y="78%" text-anchor="middle">Level ';
	string imageSvg = '</text><image href="';
	string endSvg =
		'" height="100" width="100" transform="translate(125,110)"/></svg>';

	struct Pokemon {
		string name;
		string description;
		string primaryType;
		string secondaryType;
	}

	Pokemon[] public pokemonAttributes;
	string[] pokemonColors = [
		"#78C850",
		"#F08030",
		"#6890F0",
		"#F8D030",
		"#A8A878"
	];
	string[] pokemonSprites = [
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEWM/1r///8ZGRkItTG7XGWLAAABLUlEQVQYlWMIhQMGCphRW+HM/NUwZlj//qlQ5gv7/U8hzLjF//f/gjCT+/+t/30VzPz3/9X6V0/BzL5Vq1avWgliVu0WDQ14dR/ETOF1YGCQdAIxCw4w8DMw8IGY8TwG9gceWF8FMiOabezPdfyeCmRG6Zzht5bQBzHj6hkO6EvYg5hFZQwM22/wg5gp/wQY/p/gBpvLoMTAwMAFZlodeLWawQ5sxftX/18d0AGZG7f8//9vawxA2mrW////a0PDViBzE9+qVasOMfwEMh+sARrwhuFkKEOYAvOqVesZjA+BmB+s//+wZ/oEZP74w/f/zX+mf0C1O2z4/j/4ww/Sto4ByGSwfglkZjVorlrD8GopkDnz1a3QsnNpINuqlr0NjUtbCw6SSGB4zUQNdQAmya3Mqj7AMgAAAABJRU5ErkJggg==",
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEX/AAD///8ZGRn/jACzVFtxAAABT0lEQVQYlTXQv0vDUBAH8COg+APJlMWlVQmULk6dLM0qLi1pLhGq2M1FdPAPKAjOwSE4SumiXdo/QDBVinUondxdAm6+xqWFZ897j/SGx4fjy+PuAPGojboAPUdGGWvkJBkb8m2esUq2ZJwyi2F7wbxG8MtUUN0YoU40IkuzsfFIxL/Fn1Dbfgo1LfC63Q4HAmEBFvIFGuKZKAHu/bxS4ubECrj7FFMSPogxVHu0Ofk2cr8DuNz564UTcU8DqMdpxaRFQFPwRGeUI6Hoy2IpoHWkMWB/CwNpY5P/bdqIIsJnntflsdLocKHW5Flo1Zkykdn6MueKHGjNzOGyOzOTLNuaORGzPkSUUNF34NtQOlW8GjDlraLzgYHeGfAlRo+kpmNYJxRrXkAvFWAprhnuTdlQRz2WBvqO5nnfQC/NK7rdNvrvBzqryr6LlnR3+fkHj6G+GzUv8NsAAAAASUVORK5CYII=",
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEWE1v8AjP////8ZGRnaHr/WAAABNklEQVQYlWNYBQcMRDCX/78FY15g4IUyVzMwMLyCMNcAmVIQ5hIg0wrC7GRgvCAGYc5mYPsiB2FuZ+D7EwdhzmfgvQNlujKw58ZngZirDzAwfv8DMo1hS4kLA4+NLYg5wZihVkRmKlAFwxreuwwFLK1AqxmWsF5gPOi8FCS6kvH4/4OOilEgE5gbGAwYsn+BzD28gIGX4SFIdNXWVQ3sDqlhIOa6+v+3w3XjwMzVq1bVtoKZ61evWs0zFcxc9nLVur6tdSDmyl1Zu9qmX5ufBfQxMBwYeaMOWAFFXzgt/364moEP6GMDAW3WC28Y2IDhIGvAwlggwMAOZLJ+kWGoD5BhBSpgrP/DUBriCFS7kjFuDUNs6AUxUJhVrWGIqw+tAor+z1rCELcKZAUQrHasgkfAXLS4AAC0H82Ltq/DpwAAAABJRU5ErkJggg==",
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEXmcwD///8ZGRn//wBBN5LbAAABHElEQVQYGQXBIWtWURgA4LcsmCw7wbhgULC5HzDcHSoYPu95zt29n+AVOQMnKtq0DIRF49EsKzKzNqPgH7j7AcK6BsEi83niFoC4mwBi+ggQ998CRGkN8mmK3CryyZsUtvdfnd488UP4NiS9YUt4scDRsbDextFfQl7QHxMKFHLIE1NmCv1Bc/AheR7Gw+awNV/DamKSylnYTSXZ6dYlzBuI+qyEeWNzU9QvJeymR3fs7C0ljOCzEnoYbsghQ+6sQu/hP8MVNYyGP7zXwqhpUqthlZKU9tTQtS5rT6RQz2spy+MzoX6vJS9Pfwv1dZfX5nOhPmjemS8JHZivCivwswkjuEYoMDSCNlwsBcG9X3H5JYK25XZBcD3Jn/AfjxeR4e+jK5MAAAAASUVORK5CYII=",
		"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoAgMAAADxkFD+AAAADFBMVEVaWin///8ZGRmlvVJYS6nPAAABW0lEQVQYlUXRsUtCcRAH8OuBoC0O8abaTAjbao1ni0PgkvrVzMLKbK2lLVIMmwKnH0FLVgjyoKWtSTMEy6GpPyBECBoUQyh4dt3TyN/04fjC3e+O8P/IO+b9H9YVGfpQkTNFqbchPV1FQcPWmnUNSrjtRMGXA4U9SpI90wWKftSBhK/sBUUa7VMVNIsKhLuvz6cFMyctsPTC1nPZFRDuM/MPlbaFIWa/NYldYaRjtXq32BNGp3imBwSUcJovhCoggXk2a4CeJoQ9PFdDFFJNcOGxihRWpcoWT6DyGpesddN1RdlmyM1kJLj/TQhsEV2eMAv1A/Mq2RlStbkfEz4QzvXMINZirhP8CoNYk9lLCG7iKOlkdhB2DnG8kWNZCQwHeoZmkU6ozGYaRY2cMnqlyVlNo7xw8b2c9dGV/flUKV4tZZXNkB5f/iOwouVz+ohpTZ/DiKHi6CzjY/0C4V+40iEcu6wAAAAASUVORK5CYII="
	];
	mapping(uint256 => uint256) tokenIdToPokemonIndex;
	mapping(uint256 => uint256) tokenIdToPokemonLevel;

	event NewMint(address indexed from, uint256 tokenId);

	constructor() ERC721("PK Yellow NFT Refactor", "PKYELLOW") {
		seedStarterPokemon();
	}

	function seedStarterPokemon() internal {
		pokemonAttributes.push(
			Pokemon({
				name: "Bulbasaur",
				description: "Bulbasaur can be seen napping in bright sunlight. There is a seed on its back. By soaking up the sun's rays, the seed grows progressively larger.",
				primaryType: "Grass",
				secondaryType: "Poison"
			})
		);
		pokemonAttributes.push(
			Pokemon({
				name: "Charmander",
				description: "The flame that burns at the tip of its tail is an indication of its emotions. The flame wavers when Charmander is enjoying itself. If the Pokemon becomes enraged, the flame burns fiercely.",
				primaryType: "Fire",
				secondaryType: ""
			})
		);
		pokemonAttributes.push(
			Pokemon({
				name: "Squirtle",
				description: "Squirtle's shell is not merely used for protection. The shell's rounded shape and the grooves on its surface help minimize resistance in water, enabling this Pokemon to swim at high speeds.",
				primaryType: "Water",
				secondaryType: ""
			})
		);
		pokemonAttributes.push(
			Pokemon({
				name: "Pikachu",
				description: "Whenever Pikachu comes across something new, it blasts it with a jolt of electricity. If you come across a blackened berry, it's evidence that this Pokemon mistook the intensity of its charge.",
				primaryType: "Electric",
				secondaryType: ""
			})
		);
		pokemonAttributes.push(
			Pokemon({
				name: "Eevee",
				description: "Eevee has an unstable genetic makeup that suddenly mutates due to the environment in which it lives. Radiation from various stones causes this Pokemon to evolve.",
				primaryType: "Fire",
				secondaryType: ""
			})
		);
	}

	function getTotalIssued() public view returns (uint256) {
		return _tokenIds.current();
	}

	function mintPokemon() public {
		require(
			_mintPerAddress[msg.sender] < MAX_PER_ADDRESS,
			"You have reached your minting limit."
		);
		require(
			_tokenIds.current() < MAX_MINT,
			"There are no more NFTs for minting."
		);

		_tokenIds.increment();
		uint256 newItemId = _tokenIds.current();

		uint256 starterIndex = pickStarterPokemon(newItemId);
		uint256 starterLevel = pickStarterLevel(newItemId);

		Pokemon memory starterInfo = pokemonAttributes[starterIndex];
		string memory svg = encodeSvg(starterIndex, starterLevel);
		string memory tokenUri = encodeJson(starterInfo, svg);

		tokenIdToPokemonIndex[newItemId] = starterIndex;
		tokenIdToPokemonLevel[newItemId] = starterLevel;
		_mintPerAddress[msg.sender] += 1;

		_safeMint(msg.sender, newItemId);
		_setTokenURI(newItemId, tokenUri);

		emit NewMint(msg.sender, newItemId);
	}

	function encodeSvg(uint256 pokemonIndex, uint256 level)
		internal
		view
		returns (string memory)
	{
		string memory svg = string(
			abi.encodePacked(
				baseSvg,
				pokemonColors[pokemonIndex],
				moreSvg,
				pokemonAttributes[pokemonIndex].name,
				levelSvg,
				Strings.toString(level),
				imageSvg,
				pokemonSprites[pokemonIndex],
				endSvg
			)
		);

		return svg;
	}

	function encodeJson(Pokemon memory pokemonInfo, string memory svg)
		internal
		pure
		returns (string memory)
	{
		string memory json = Base64.encode(
			bytes(
				string(
					abi.encodePacked(
						'{"name": "',
						pokemonInfo.name,
						'", "description": "',
						pokemonInfo.description,
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

		return tokenUri;
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
					block.timestamp, // NOTE: adds a little touch of randomness, but keep in mind that this is insecure for mainnet
					Strings.toString(tokenId)
				)
			)
		);
		return rand % pokemonAttributes.length;
	}

	function pickStarterLevel(uint256 tokenId) private view returns (uint256) {
		uint256 rand = random(
			string(
				abi.encodePacked(
					"LEVEL",
					block.timestamp, // NOTE: adds a little touch of randomness, but keep in mind that this is insecure for mainnet
					Strings.toString(tokenId)
				)
			)
		);
		return (rand % 80) + 5;
	}
}
