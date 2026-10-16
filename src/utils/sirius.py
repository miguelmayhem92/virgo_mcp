import pandas as pd
import boto3
import os
from datetime import datetime
import requests
import json

from dotenv import load_dotenv


load_dotenv()

class AssetReader:
    def __init__(self, bucket):
        self.bucket = bucket

    def sirius_read_csv(self, asset, n=20):
        df = pd.read_csv(f"s3://{self.bucket}/edge_models/sirius/{asset}/sirius_{asset}_edges.csv", sep=";")
        return df.sort_values("Date",ascending=False)[["Date", "proba_target_up", "proba_target_down"]].head(n)

    @staticmethod
    def produce_text(data, asset):
        lines=[f"asset {asset} current provabilities and dates are: "]
        for d, up, down in zip(data['Date'], data['proba_target_up'], data['proba_target_down']):
            date_text = datetime.strptime(d, "%Y-%m-%d").strftime("%Y-%B-%d")
            lines.append(
                f"On {date_text}, the probability that the target goes up is {up*100:.2f}%, "
                f"and the probability that it goes down is {down*100:.2f}%."
            )

        text = "\n".join(lines)
        return text

    @staticmethod
    def mean_probs_to_string(df: dict, asset:str) -> str:
        data = df[["proba_target_up","proba_target_down"]].mean().to_dict()
        up = data["proba_target_up"]
        down = data["proba_target_down"]
        return (
            f"{asset} Probability of target going up: {up:.{2}f} "
            f"({up:.1%}). "
            f"{asset} Probability of target going down: {down:.{2}f} "
            f"({down:.1%})."
        )
    
    @staticmethod
    def launch_sirius_lambda(asset):
        payload = {'asset': asset}
        url = os.getenv("edge_models_api_url")
        api_key = os.getenv("api_key")
        if not url or not api_key:
            raise Exception("error geting creds for launching lambda")
        
        headers = {'X-API-Key':api_key}
        response = requests.post(url, json  = payload, headers=headers)
        result = json.loads(response.text)
        return result