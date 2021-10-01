const fs = require("fs");
const { exec } = require("child_process");

async function deploy() {
	const factory = await hre.ethers.getContractFactory("PkYellowNft");
	const contract = await factory.deploy();
	await contract.deployed();
	console.log("Contract deployed to:", contract.address);

	let txn = await contract.mintPokemon();
	await txn.wait();

	fs.writeFileSync("contract-address.json", JSON.stringify(contract.address));

	exec("mkdir -p rinkeby");
	exec("mv contract-address.json rinkeby/address.json");
	exec(
		"cp artifacts/contracts/PkYellowNft.sol/PkYellowNft.json rinkeby/abi.json",
	);
}

async function main() {
	try {
		await deploy();
		process.exit(0);
	} catch (error) {
		console.error(error);
		process.exit(1);
	}
}

main();
