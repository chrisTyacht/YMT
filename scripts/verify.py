import token
from brownie import config, accounts, YachtMasterToken
from scripts.common_funcs import retrieve_account
import time
import os
from dotenv import load_dotenv
from brownie import project

load_dotenv()  # take environment variables from .env.


def main():
    token = YachtMasterToken.at("0x1aab818471072e85453A09fEb4aC615618AC4306")
    YachtMasterToken.publish_source(token)
    