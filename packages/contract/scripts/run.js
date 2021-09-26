async function deploy() {
	const factory = await hre.ethers.getContractFactory("PkYellowNft");
	const contract = await factory.deploy();
	await contract.deployed();
	console.log("Contract deployed to:", contract.address);

	let txn = await contract.mintPokemon();
	await txn.wait();

	txn = await contract.mintPokemon();
	await txn.wait();
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
