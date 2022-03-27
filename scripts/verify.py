import token
from brownie import config, accounts, YachtMasterToken
from scripts.common_funcs import retrieve_account
import time
import os
from dotenv import load_dotenv
from brownie import project

load_dotenv()  # take environment variables from .env.


def main():
    token = YachtMasterToken.at("0x6EB4BB98cE7582080B7f04457AA1a9A416B26888")
    YachtMasterToken.publish_source(token)
    