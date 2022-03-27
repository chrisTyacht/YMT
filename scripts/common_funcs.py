from brownie import config, accounts
import time
import os
from dotenv import load_dotenv

load_dotenv()

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
DONT_PUBLISH_SOURCE_ENVIRONMENTS = ["development", "ganache-local"]

DECIMALS = 18

def retrieve_account(accountNum=1):
        fromKeyNum = f"_{accountNum}" if accountNum != 1 else ""
        print(config["wallets"][f"from_key{fromKeyNum}"])
        return accounts.add(config["wallets"][f"from_key{fromKeyNum}"])

def waitForTransactionsToComplete():
    time.sleep(0.1)