import os
import re
import json

def main():
    # Load the Arabic translations to create the reverse mapping
    ar_json_path = r'd:\mobile-acc\assets\translations\ar.json'
    with open(ar_json_path, 'r', encoding='utf-8') as f:
        ar_dict = json.load(f)
        
    # Map arabic string -> translation key
    # Sort by length descending to replace longer strings first (avoids substring issues if any, though regex exact match handles it mostly)
    reverse_map = {v: k for k, v in ar_dict.items()}
    sorted_arabic_strings = sorted(reverse_map.keys(), key=len, reverse=True)
    
    import_statement = "import 'package:easy_localization/easy_localization.dart';"
    
    # Iterate through all dart files
    for root, dirs, files in os.walk(r'd:\mobile-acc\lib'):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                modifications = 0
                
                for ar_str in sorted_arabic_strings:
                    key = reverse_map[ar_str]
                    
                    # Regex to match exact string literals containing ONLY the arabic text
                    # e.g., 'المبيعات' or "المبيعات"
                    # We avoid replacing things like 'المبيعات: $total'
                    pattern = r"(?P<quote>['\"])" + re.escape(ar_str) + r"(?P=quote)"
                    
                    # Replacement: 'key'.tr()
                    replacement = r"\g<quote>" + key + r"\g<quote>.tr()"
                    
                    content, num_subs = re.subn(pattern, replacement, content)
                    modifications += num_subs
                    
                if modifications > 0:
                    # Check if easy_localization is imported
                    if import_statement not in content:
                        # Find the last import statement to insert after it, or insert at top
                        imports_end = 0
                        for m in re.finditer(r"^import\s+['\"].*?['\"];", content, re.MULTILINE):
                            imports_end = m.end()
                            
                        if imports_end > 0:
                            content = content[:imports_end] + "\n" + import_statement + content[imports_end:]
                        else:
                            content = import_statement + "\n\n" + content
                            
                    # Save the modified file
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                        
    print("Done replacing.")

if __name__ == '__main__':
    main()
