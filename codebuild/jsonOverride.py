import json
import sys
with open(sys.argv[1],"rb") as f:
    data = json.load(f)
override=json.loads(sys.argv[2])
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)
for i in range(len(data)):
    for j in override:
        if data[i].get("name")==j:
            r=override[j]
            o=data[i]["value"]
            eprint("Found",j," and value ",o," being replaced to ",r)
            data[i]["value"]=override[j]
            break
print(json.dumps(data,indent=2, sort_keys=False, ensure_ascii=False))

