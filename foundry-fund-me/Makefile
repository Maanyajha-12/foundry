include .env
build:; forge build
deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --broadcast --rpc-url ${SEPOLIA_RPC_URL}  --private-key ${PRIVATE_KEY}   -vvvv
	