import requests
import base64
import time
import tempfile
import os
import subprocess
from openai import OpenAI

# ========== 配置区 ==========
IMMICH_URL = "http://192.168.6.165:2283/api"
IMMICH_API_KEY = "Immich的API_KEY"
MODEL_NAME = "gemini-3.1-flash-lite-preview"

client = OpenAI(
    api_key="AI API的KEY",
    base_url="API接口",
    default_headers={
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        "Accept": "application/json",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        "Origin": "https://api.chatanywhere.tech",
        "Referer": "https://api.chatanywhere.tech/",
    }
)

headers = {
    "x-api-key": IMMICH_API_KEY,
    "Accept": "application/json"
}

def get_asset_detail(asset_id):
    url = f"{IMMICH_URL}/assets/{asset_id}"
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    return resp.json()

def download_asset(asset_id):
    url = f"{IMMICH_URL}/assets/{asset_id}/original"
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    return resp.content

def preprocess_image(image_bytes, filename=""):
    """预处理图片：HEIC转JPEG、压缩大图"""
    if filename.lower().endswith('.heic'):
        with tempfile.NamedTemporaryFile(suffix='.heic', delete=False) as f:
            f.write(image_bytes)
            heic_path = f.name
        jpg_path = heic_path.replace('.heic', '.jpg')
        subprocess.run(['convert', heic_path, jpg_path], check=True, timeout=30)
        with open(jpg_path, 'rb') as f:
            image_bytes = f.read()
        os.remove(heic_path)
        os.remove(jpg_path)

    max_size = 5 * 1024 * 1024
    if len(image_bytes) > max_size:
        with tempfile.NamedTemporaryFile(suffix='.jpg', delete=False) as f:
            f.write(image_bytes)
            in_path = f.name
        out_path = in_path.replace('.jpg', '_compressed.jpg')
        subprocess.run(
            ['convert', in_path, '-resize', '1920x1920>', '-quality', '85', out_path],
            check=True, timeout=30
        )
        with open(out_path, 'rb') as f:
            image_bytes = f.read()
        os.remove(in_path)
        os.remove(out_path)
    
    return image_bytes

def process_image(image_bytes, filename="", existing_desc=""):
    """处理图片：无描述则生成描述+关键词，有描述则只生成关键词"""
    image_bytes = preprocess_image(image_bytes, filename)
    image_b64 = base64.b64encode(image_bytes).decode("utf-8")
    
    if not existing_desc:
        # 无描述：生成描述和关键词
        prompt = """请分析这张照片，完成两个任务：
1. 生成描述：用1-3句中文简略描述这张照片的整体内容。
2. 生成关键词：根据图片内容生成5-15个准确的关键词/标签，便于搜索。

请按以下格式返回：
【描述】
你的描述内容
【关键词】
关键词1,关键词2,关键词3"""
    else:
        # 有描述：只生成关键词
        prompt = f"""基于图片内容和以下现有描述，使用中文生成5-15个准确的关键词/标签。
直接返回关键词列表，用英文逗号分隔，不要有其他文字。

现有描述：{existing_desc}

关键词："""
    
    completion = client.chat.completions.create(
        model=MODEL_NAME,
        messages=[{
            "role": "user",
            "content": [
                {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{image_b64}"}},
                {"type": "text", "text": prompt}
            ]
        }],
        max_tokens=1000 if not existing_desc else 800,
        temperature=0.7,
        stream=False
    )
    
    result = completion.choices[0].message.content.strip()
    
    if not existing_desc:
        # 解析描述和关键词
        if "【描述】" in result and "【关键词】" in result:
            parts = result.split("【关键词】")
            desc_part = parts[0].replace("【描述】", "").strip()
            keywords = parts[1].strip() if len(parts) > 1 else ""
        else:
            # 降级处理
            lines = result.split('\n')
            desc_part = lines[0] if lines else result
            keywords = next((line for line in lines if ',' in line), "")
        
        keywords = keywords.replace('\n', '').replace('关键词：', '').replace(':', '')
        return desc_part, keywords
    else:
        keywords = result.replace('\n', '').replace('关键词：', '').replace(':', '')
        return keywords

def update_description(asset_id, description):
    url = f"{IMMICH_URL}/assets/{asset_id}"
    resp = requests.put(url, json={"description": description}, headers=headers)
    resp.raise_for_status()

# ========== 主流程 ==========
page = 1
total = 0

while True:
    print(f"正在查找第 {page} 页...")
    resp = requests.post(
        f"{IMMICH_URL}/search/metadata",
        json={"type": "IMAGE", "page": page, "size": 50},
        headers=headers
    )
    resp.raise_for_status()
    items = resp.json()["assets"]["items"]
    
    if not items:
        print("没有更多照片了")
        break
    
    for photo in items:
        asset_id = photo["id"]
        filename = photo.get("originalFileName", "unknown")
        
        try:
            detail = get_asset_detail(asset_id)
            current_desc = detail.get("exifInfo", {}).get("description") or ""
            
            # 检查是否需要处理（无描述 或 有描述但无关键词）
            need_process = False
            if not current_desc.strip():
                need_process = True
                print(f"\n[{total + 1}] 处理(描述+关键词): {filename}")
            elif '\n' not in current_desc or ',' not in current_desc.split('\n')[-1]:
                need_process = True
                print(f"\n[{total + 1}] 处理(添加关键词): {filename}")
            
            if need_process:
                image_bytes = download_asset(asset_id)
                
                if not current_desc.strip():
                    description, keywords = process_image(image_bytes, filename)
                    new_description = f"{description}\n{keywords}"
                    print(f"  描述: {description}")
                    print(f"  关键词: {keywords}")
                else:
                    keywords = process_image(image_bytes, filename, current_desc)
                    new_description = f"{current_desc}\n{keywords}"
                    print(f"  原描述: {current_desc[:50]}...")
                    print(f"  关键词: {keywords}")
                
                update_description(asset_id, new_description)
                print(f" 已保存")
                total += 1
                time.sleep(2)
                
        except Exception as e:
            print(f" 处理失败: {e}")
    
    page += 1

print(f"\n完成! 共处理 {total} 张照片")
