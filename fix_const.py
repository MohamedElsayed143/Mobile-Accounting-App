import os
import re
import subprocess

def fix_const_errors():
    lib_dir = r'd:\mobile-acc\lib'
    
    # We will repeatedly run `flutter analyze` until no const errors are found
    # Or just do a sweeping regex replacement first to catch 90% of them
    
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace `const Text` with `Text` when .tr() is on the same line
                # Actually, just replace `const ` on any line that has `.tr()`
                lines = content.split('\n')
                modified = False
                
                for i in range(len(lines)):
                    if '.tr()' in lines[i]:
                        # Remove `const ` from the same line
                        if 'const ' in lines[i]:
                            lines[i] = lines[i].replace('const ', '')
                            modified = True
                            
                        # Also check the previous line just in case `const` was alone on it
                        if i > 0 and lines[i-1].strip() == 'const':
                            lines[i-1] = lines[i-1].replace('const', '')
                            modified = True
                            
                        # Or if `const ` is on the previous line before a newline
                        if i > 0 and lines[i-1].rstrip().endswith('const'):
                            lines[i-1] = re.sub(r'const$', '', lines[i-1].rstrip())
                            modified = True
                            
                # Sometimes it's `children: const [` and `.tr()` is inside.
                # It's better to just use a regex over the whole content:
                # Find `const ` followed by anything up to `.tr()` without any `;` or `{` in between
                # This is dangerous.
                
                if modified:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write('\n'.join(lines))

if __name__ == '__main__':
    fix_const_errors()
