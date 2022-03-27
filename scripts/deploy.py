from brownie import network, config, YachtMasterToken
from web3 import Web3
from scripts.common_funcs import retrieve_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS, DONT_PUBLISH_SOURCE_ENVIRONMENTS
import os
from dotenv import load_dotenv

load_dotenv()

INITIAL_SUPPLY = Web3.toWei(100000000000, "ether")

PROD_YACHT_MASTER_ADDRESS = "0x4cAC359ab2A020CF212D82C1b66fC8abF81b1Dd0"
PROD_MARKETING_ADDRESS = "0x0C610203A017711977947ac91be02A1023c482F0"
PROD_DEVELOPER_ADDRESS = "0x5fDa1dEc47b50AFfF74B1387f7f0E9EF18ed98B2"
PROD_LIQUIDITY_ADDRESS = "0x2A0B1827488ACbB79A363A7DCf35424b18208fC4"
PROD_TBBURNT_ADDRESS = "0xCC59e2e4cf86df813DaD356021562a59785923Ae"
PROD_AIRDROP_ADDRESS = "0xe5840701202488bE8284EA3e5e2bF7Ad1965dC7E"

PROD = False

def deploy_yacht_master(yachtMasterWalletAddress=None, marketingWalletAddress=None, developerWalletAddress=None, liquidityWalletAddress=None, tobeburntWalletAddress=None, airDropWalletAddress=None, burnWalletAddress=None):
    
    currNetwork = network.show_active()
    if PROD and currNetwork in config["networks"] and "pancakeswap_router" and "pinkAntiBot" in config["networks"][currNetwork]:
        yachtMasterWalletAddress = PROD_YACHT_MASTER_ADDRESS
        marketingWalletAddress = PROD_MARKETING_ADDRESS
        developerWalletAddress = PROD_DEVELOPER_ADDRESS
        liquidityWalletAddress = PROD_LIQUIDITY_ADDRESS
        tobeburntWalletAddress = PROD_TBBURNT_ADDRESS
        airDropWalletAddress = PROD_AIRDROP_ADDRESS
        
    else:
        if not yachtMasterWalletAddress:
            account = retrieve_account()
            yachtMasterWalletAddress = account.address
        if not marketingWalletAddress:
            account_two = retrieve_account(2)
            marketingWalletAddress = account_two.address
        if not developerWalletAddress:
            account_three = retrieve_account(3)
            developerWalletAddress = account_three.address
        if not liquidityWalletAddress:
            account_four = retrieve_account(4)
            liquidityWalletAddress = account_four.address
        if not tobeburntWalletAddress:
            account_five = retrieve_account(5)
            tobeburntWalletAddress = account_five.address
        if not airDropWalletAddress:
            account_six = retrieve_account(6)
            airDropWalletAddress = account_six.address
        
    if currNetwork in config["networks"] and "pancakeswap_router" in config["networks"][currNetwork]:
        pancakeSwapRouterAddress = config["networks"][currNetwork]["pancakeswap_router"]
        
    if currNetwork in config["networks"] and "pinkAntiBot" in config["networks"][currNetwork]:
        pinkAntiBotAddress = config["networks"][currNetwork]["pinkAntiBot"]

    yachtMasterToken = YachtMasterToken.deploy(
        INITIAL_SUPPLY,
        yachtMasterWalletAddress,
        marketingWalletAddress,
        developerWalletAddress,
        liquidityWalletAddress,
        tobeburntWalletAddress,
        airDropWalletAddress,
        pancakeSwapRouterAddress,
        pinkAntiBotAddress,
        {"from": account}
    )

    if type(yachtMasterToken) == 'TransactionReceipt':
        yachtMasterToken.wait(1)
        yachtMasterToken = yachtMasterToken.return_value

    print(f"Yacht Master Token deployed to {yachtMasterToken.address}")

    return YachtMasterToken
    
def main():
    deploy_yacht_master()