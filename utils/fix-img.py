import os
import re
from pathlib import Path

def rename_assets_and_update_references():
    # 配置路径
    assets_dir = Path("assets")
    readme_path = Path("README.md")
    
    # 获取所有图片文件并按修改时间排序
    image_files = sorted(
        [f for f in assets_dir.iterdir() if f.is_file() and f.suffix.lower() in {'.png', '.jpg', '.jpeg', '.gif'}],
        key=lambda x: x.stat().st_mtime
    )
    
    # 生成文件名映射关系
    name_mapping = {}
    for idx, file in enumerate(image_files, 1):
        new_name = f"{idx}{file.suffix}"
        new_path = file.with_name(new_name)
        file.rename(new_path)
        name_mapping[file.name] = new_name
    
    # 更新README.md中的引用
    if readme_path.exists():
        with open(readme_path, 'r+', encoding='utf-8') as f:
            content = f.read()
            
            # 使用正则表达式替换所有图片引用
            pattern = re.compile(
                r'(!\[.*?\]\()'  # 匹配Markdown图片语法开头
                r'(assets/.*?)'  # 匹配原文件名
                r'(\))',         # 匹配结尾括号
                re.DOTALL
            )
            
            def replace_match(match):
                prefix = match.group(1)
                old_name = match.group(2).split('assets/')[-1]
                suffix = match.group(3)
                return f"{prefix}assets/{name_mapping.get(old_name, old_name)}{suffix}"
            
            new_content = pattern.sub(replace_match, content)
            
            # 回写文件
            f.seek(0)
            f.write(new_content)
            f.truncate()

if __name__ == "__main__":
    rename_assets_and_update_references()
    print("操作完成！图片已重命名并更新文档引用。")
