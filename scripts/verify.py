import token
from brownie import config, accounts, YachtMasterToken
from scripts.common_funcs import retrieve_account
import time
import os
from dotenv import load_dotenv
from brownie import project

load_dotenv()  # take environment variables from .env.


def main():
    token = YachtMasterToken.at("0x60819665a60aE5105c2910fD43C39f44632c331f")
    YachtMasterToken.publish_source(token)
    