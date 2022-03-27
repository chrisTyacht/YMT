from brownie import config, accounts
from web3 import Web3
import time
import os
from dotenv import load_dotenv
load_dotenv()  # take environment variables from .env.

def retrieve_account(accountNum=1):
        fromKeyNum = f"_{accountNum}" if accountNum != 1 else ""
        return accounts.add(config["wallets"][f"from_key{fromKeyNum}"])

print(retrieve_account(3))