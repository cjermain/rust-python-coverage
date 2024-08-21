#!/usr/bin/env bash

# Function to remove a directory and print the action
remove_dir() {
    if [ -d "$1" ]; then
        echo "Removing directory: $1"
        rm -rf "$1"
    fi
}

# Function to remove a file and print the action
remove_file() {
    if [ -f "$1" ]; then
        echo "Removing file: $1"
        rm -f "$1"
    fi
}

# Remove .pytest_cache directory
remove_dir .pytest_cache/

# Remove target directory
remove_dir target/

# Remove any __pycache__ directories
find python/ -type d -name "__pycache__" -print | while read -r dir; do
    remove_dir "$dir"
done

# Remove pytest-coverage.lcov file
remove_file .coverage
remove_file pytest-coverage.lcov

# Remove rust-coverage.lcov file
remove_file rust-coverage.lcov

# Remove pyo3 files
find python/ -type f -name '_internal.*.so' -print | while read -r file; do
    remove_file "$file"
done

echo "Cleanup complete."