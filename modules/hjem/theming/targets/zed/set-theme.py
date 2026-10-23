#!/usr/bin/env python3
"""Set the Zed theme key without disturbing the rest of settings.json.

Zed accepts JSONC, so the file may contain comments and trailing commas. A
full parse would rewrite the user's file, so this only replaces the value of
the top-level "theme" key.
"""

import json
import os
import sys


def skip_space(text, i):
    n = len(text)
    while i < n:
        if text[i] in " \t\r\n":
            i += 1
        elif text.startswith("//", i):
            end = text.find("\n", i)
            i = n if end == -1 else end + 1
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = n if end == -1 else end + 2
        else:
            break
    return i


def string_end(text, i):
    n = len(text)
    i += 1
    while i < n:
        if text[i] == "\\":
            i += 2
        elif text[i] == '"':
            return i + 1
        else:
            i += 1
    return n


def container_end(text, i):
    pairs = {"{": "}", "[": "]"}
    stack = [pairs[text[i]]]
    i += 1
    n = len(text)

    while i < n:
        c = text[i]
        if c == '"':
            i = string_end(text, i)
            continue
        if text.startswith("//", i):
            end = text.find("\n", i)
            i = n if end == -1 else end + 1
            continue
        if text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = n if end == -1 else end + 2
            continue
        if c in pairs:
            stack.append(pairs[c])
        elif c in "}]":
            if stack and c == stack[-1]:
                stack.pop()
                if not stack:
                    return i + 1
        i += 1

    return n


def value_end(text, i):
    if i >= len(text):
        return i
    if text[i] == '"':
        return string_end(text, i)
    if text[i] in "{[":
        return container_end(text, i)

    n = len(text)
    while i < n and text[i] not in ",}] \t\r\n":
        i += 1
    return i


def find_theme(text):
    i = 0
    n = len(text)
    depth = 0

    while i < n:
        c = text[i]

        if c == '"':
            end = string_end(text, i)
            if depth == 1:
                try:
                    key = json.loads(text[i:end])
                except json.JSONDecodeError:
                    key = None

                j = skip_space(text, end)
                if key == "theme" and j < n and text[j] == ":":
                    start = skip_space(text, j + 1)
                    return start, value_end(text, start)
            i = end
            continue

        if text.startswith("//", i):
            end = text.find("\n", i)
            i = n if end == -1 else end + 1
            continue
        if text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = n if end == -1 else end + 2
            continue

        if c in "{[":
            depth += 1
        elif c in "}]":
            depth -= 1
        i += 1

    return None


def main():
    path = sys.argv[1]
    theme = sys.argv[2]

    if not os.path.exists(path):
        with open(path, "w") as handle:
            handle.write(json.dumps({"theme": theme}, indent=2) + "\n")
        return

    with open(path) as handle:
        text = handle.read()

    found = find_theme(text)
    value = json.dumps(theme)

    if found is not None:
        start, end = found
        text = text[:start] + value + text[end:]
    else:
        opening = text.find("{")
        if opening == -1:
            text = json.dumps({"theme": theme}, indent=2) + "\n"
        else:
            after = skip_space(text, opening + 1)
            if after < len(text) and text[after] == "}":
                insertion = "\n  \"theme\": " + value + "\n"
            else:
                insertion = "\n  \"theme\": " + value + ","
            text = text[: opening + 1] + insertion + text[opening + 1 :]

    with open(path, "w") as handle:
        handle.write(text)


if __name__ == "__main__":
    main()
