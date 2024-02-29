#!/usr/bin/env python3

import os
import sys
import glob
import shutil
import fnmatch


def delete_files(root_dir, gitignore_path):
    with open(gitignore_path, "r") as file:
        exclusion_patterns = set()

        for line in file:
            line = line.strip()
            if line and not line.startswith("#"):
                if line.startswith("!"):
                    # Exclusion pattern, add it to the set
                    exclusion_patterns.add(os.path.join(root_dir, line[1:]))
                else:
                    pattern = os.path.join(root_dir, line)
                    for file_to_delete in glob.glob(pattern, recursive=True):
                        try:
                            if os.path.isfile(file_to_delete) and not any(
                                fnmatch.fnmatch(file_to_delete, exclusion_pattern)
                                for exclusion_pattern in exclusion_patterns
                            ):
                                # print(f"Deleting file: {file_to_delete}")
                                os.remove(file_to_delete)
                            elif os.path.isdir(file_to_delete):
                                # print(f"Deleting directory and its contents: {file_to_delete}")
                                shutil.rmtree(file_to_delete)
                        except Exception as e:
                            print(f"Error deleting {file_to_delete}: {str(e)}")


def main():
    if len(sys.argv) != 3:
        print("Usage: python clean_script.py <root_dir> <path_to_gitignore>")
        sys.exit(1)

    root_dir = sys.argv[1]
    gitignore_path = sys.argv[2]

    delete_files(root_dir, gitignore_path)


if __name__ == "__main__":
    main()
