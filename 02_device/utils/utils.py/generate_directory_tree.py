#!/usr/bin/env python3

import os

def get_directory_tree(startpath):
    tree = []
    for root, dirs, files in os.walk(startpath):
        level = root.replace(startpath, '').count(os.sep)
        indent = ' ' * 4 * level
        tree.append('{}{}/'.format(indent, os.path.basename(root)))
        subindent = ' ' * 4 * (level + 1)
        for d in dirs:
            comment = input(f"Enter comment for {d}: ")
            tree.append('{}{}  # {}'.format(subindent, d, comment))
    return '\n'.join(tree)

startpath = input("Enter the path of the directory: ")
directory_tree = get_directory_tree(startpath)

with open("annotated_tree.txt", "w") as f:
    f.write(directory_tree)