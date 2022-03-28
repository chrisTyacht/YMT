import token
from brownie import config, accounts, YachtMasterToken
from scripts.common_funcs import retrieve_account
import time
import os
from dotenv import load_dotenv
from brownie import project

load_dotenv()  # take environment variables from .env.


def main():
    account = retrieve_account()
    contract = YachtMasterToken[-1]
    tx = contract.burn(1000000000000000000000000000, {'from': account})
    tx.wait(1)