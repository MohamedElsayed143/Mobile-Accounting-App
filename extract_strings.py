import os
import re
import json

def main():
    arabic_pattern = re.compile(r"(['\"])([^'\"\r\n]*?[\u0600-\u06FF]+[^'\"\r\n]*?)\1")
    strings = set()
    for root, dirs, files in os.walk(r'd:\mobile-acc\lib'):
        for file in files:
            if file.endswith('.dart'):
                with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                    for line in f:
                        for match in arabic_pattern.findall(line):
                            # clean up any interpolations starting with $
                            cleaned = re.sub(r'\$\{.*?\}|\$\w+', '', match[1]).strip()
                            if cleaned and any('\u0600' <= c <= '\u06FF' for c in cleaned):
                                strings.add(cleaned)
                                
    with open(r'd:\mobile-acc\extracted_strings_clean.json', 'w', encoding='utf-8') as f:
        json.dump(list(strings), f, ensure_ascii=False, indent=2)

if __name__ == '__main__':
    main()
