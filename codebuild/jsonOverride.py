import json
import sys
with open(sys.argv[1],"rb") as f:
    data = json.load(f)
override=json.loads(sys.argv[2])
for i in range(len(data)):
    for j in override:
        if data[i].get("name")==j:
            data[i]["value"]=override[j]
            break
print(json.dumps(data,indent=2, sort_keys=False, ensure_ascii=False))

