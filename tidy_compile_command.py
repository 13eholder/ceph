import json

# 读取 compile_commands.json 文件
with open('./build_nodashboard/compile_commands.json', 'r') as f:
    data = json.load(f)

# 修改 command 字段
for entry in data:
    entry['command'] = entry['command'].replace('-fno-new-ttp-matching', '')


# 写回文件
with open('./build_nodashboard/compile_commands.json', 'w') as f:
    json.dump(data, f, indent=2)

print("已成功删除指定选项。")
