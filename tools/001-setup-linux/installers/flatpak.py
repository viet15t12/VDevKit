from __future__ import annotations

from collections.abc import Iterable

from .common import Runner


def install_flatpaks(runner: Runner, refs: Iterable[str]) -> bool:
    applications = list(dict.fromkeys(refs))
    if not applications:
        return True
    return runner.run(
        "Cài ứng dụng Flatpak",
        ["flatpak", "install", "-y", "--noninteractive", "flathub", *applications],
    )
