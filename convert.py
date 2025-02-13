import sys
import re

def replace_special_chars(s):
    replacements = {
        'ö': '&ouml;',   'Ö': '&Ouml;',
        'ä': '&auml;',   'Ä': '&Auml;',
        'ü': '&uuml;',   'Ü': '&Uuml;',
        'õ': '&otilde;', 'Õ': '&Otilde;',
        'š': '&scaron;', 'Š': '&Scaron;',
        'ž': '&zcaron;', 'Ž': '&Zcaron;'
    }
    count_map = { key: 0 for key in replacements }
    def replacer(match):
        char = match.group(0)
        count_map[char] += 1
        return replacements[char]

    pattern = r'[öÖäÄüÜõÕšŠžŽ]'
    result = re.sub(pattern, replacer, s)

    print(result)

    total_replacements = sum(count_map.values())
    if total_replacements == 0:
        print("No special symbols found")
    else:
        print("Replaced:")
        for letter in replacements:
            if count_map[letter] > 0:
                print(f"{letter}: {count_map[letter]}")
        print(f"Total: {total_replacements}")

if __name__ == "__main__":
    input_str = " ".join(sys.argv[1:])
    replace_special_chars(input_str)
