#!/usr/bin/env python3
"""
Generate random Fullwidth Japanese characters.
Includes Hiragana (ひらがな), Katakana (カタカナ), and Fullwidth alphanumeric (全角英数字).
"""

import random
import argparse


# Unicode ranges for Japanese characters
HIRAGANA_START = 0x3040
HIRAGANA_END = 0x309F

KATAKANA_START = 0x30A0
KATAKANA_END = 0x30FF

# Fullwidth alphanumeric characters
FULLWIDTH_DIGIT_START = 0xFF10  # ０
FULLWIDTH_DIGIT_END = 0xFF19    # ９
FULLWIDTH_UPPER_START = 0xFF21  # Ａ
FULLWIDTH_UPPER_END = 0xFF3A    # Ｚ
FULLWIDTH_LOWER_START = 0xFF41  # ａ
FULLWIDTH_LOWER_END = 0xFF5A    # ｚ


def get_hiragana_chars():
    """Get list of valid hiragana characters."""
    # Exclude combining marks and special characters
    exclude = {
        0x3099,  # Combining voiced sound mark (dakuten)
        0x309A,  # Combining semi-voiced sound mark (handakuten)
        0x309B,  # Katakana-hiragana voiced sound mark
        0x309C,  # Katakana-hiragana semi-voiced sound mark
    }
    return [chr(i) for i in range(HIRAGANA_START, HIRAGANA_END + 1) if i not in exclude]


def get_katakana_chars():
    """Get list of valid katakana characters."""
    # Exclude combining marks and special characters
    exclude = {
        0x30FB,  # Katakana middle dot
        0x30FC,  # Katakana-hiragana prolonged sound mark
    }
    return [chr(i) for i in range(KATAKANA_START, KATAKANA_END + 1) if i not in exclude]


def get_fullwidth_alphanumeric_chars():
    """Get list of fullwidth alphanumeric characters."""
    chars = []
    # Digits 0-9
    chars.extend([chr(i) for i in range(FULLWIDTH_DIGIT_START, FULLWIDTH_DIGIT_END + 1)])
    # Uppercase A-Z
    chars.extend([chr(i) for i in range(FULLWIDTH_UPPER_START, FULLWIDTH_UPPER_END + 1)])
    # Lowercase a-z
    chars.extend([chr(i) for i in range(FULLWIDTH_LOWER_START, FULLWIDTH_LOWER_END + 1)])
    return chars


def generate_random_chars(count=10, include_hiragana=True, include_katakana=True,
                         include_alphanumeric=True):
    """
    Generate random fullwidth Japanese characters.

    Args:
        count: Number of characters to generate
        include_hiragana: Include hiragana characters
        include_katakana: Include katakana characters
        include_alphanumeric: Include fullwidth alphanumeric characters

    Returns:
        String of random characters
    """
    char_pool = []

    if include_hiragana:
        char_pool.extend(get_hiragana_chars())

    if include_katakana:
        char_pool.extend(get_katakana_chars())

    if include_alphanumeric:
        char_pool.extend(get_fullwidth_alphanumeric_chars())

    if not char_pool:
        raise ValueError("At least one character type must be selected")

    return ''.join(random.choices(char_pool, k=count))


def main():
    parser = argparse.ArgumentParser(
        description='Generate random Fullwidth Japanese characters',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -n 20
  %(prog)s -n 50 --no-hiragana
  %(prog)s -n 30 --only-katakana
  %(prog)s -n 15 --only-alphanumeric
        """
    )

    parser.add_argument('-n', '--count', type=int, default=10,
                       help='Number of characters to generate (default: 10)')

    parser.add_argument('--no-hiragana', action='store_true',
                       help='Exclude hiragana characters')
    parser.add_argument('--no-katakana', action='store_true',
                       help='Exclude katakana characters')
    parser.add_argument('--no-alphanumeric', action='store_true',
                       help='Exclude fullwidth alphanumeric characters')

    parser.add_argument('--only-hiragana', action='store_true',
                       help='Generate only hiragana characters')
    parser.add_argument('--only-katakana', action='store_true',
                       help='Generate only katakana characters')
    parser.add_argument('--only-alphanumeric', action='store_true',
                       help='Generate only fullwidth alphanumeric characters')

    args = parser.parse_args()

    # Handle "only" flags
    if args.only_hiragana:
        include_hiragana = True
        include_katakana = False
        include_alphanumeric = False
    elif args.only_katakana:
        include_hiragana = False
        include_katakana = True
        include_alphanumeric = False
    elif args.only_alphanumeric:
        include_hiragana = False
        include_katakana = False
        include_alphanumeric = True
    else:
        # Handle "no" flags
        include_hiragana = not args.no_hiragana
        include_katakana = not args.no_katakana
        include_alphanumeric = not args.no_alphanumeric

    try:
        result = generate_random_chars(
            count=args.count,
            include_hiragana=include_hiragana,
            include_katakana=include_katakana,
            include_alphanumeric=include_alphanumeric
        )
        print(result)
    except ValueError as e:
        parser.error(str(e))


if __name__ == '__main__':
    main()
