import token
from brownie import config, accounts, YachtMasterToken
from scripts.common_funcs import retrieve_account
import time
import os
from dotenv import load_dotenv
from brownie import project

load_dotenv()  # take environment variables from .env.


def main():
    token = YachtMasterToken.at("0x03913ae96D24d8C29Ea375F01611E34C0581c187")
    YachtMasterToken.publish_source(token)
    