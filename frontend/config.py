import json
import os

host = os.environ['HOST']
filename = "./config.json"
with open(filename, "r") as jsonFile:
    data = json.load(jsonFile)
data["host"] = host
with open(filename, "w") as jsonFile:
    json.dump(data, jsonFile)
