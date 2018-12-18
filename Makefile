format:
	find "macOS SDK v4 Sample" -type f \( -name '*.m' -o -name '*.h' \) -exec clang-format -i -style=file {} \;

generate-english-strings:
	find "macOS SDK v4 Sample" -name '*.m' -exec genstrings -o "macOS SDK v4 Sample/Base.lproj" "{}" \;	

