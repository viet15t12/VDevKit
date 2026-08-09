from __future__ import annotations

from collections.abc import Iterable

from .common import Runner


def enable_services(runner: Runner, services: Iterable[str]) -> bool:
    units = list(dict.fromkeys(services))
    if not units:
        return True
    return runner.run(
        "Bật systemd services",
        ["sudo", "systemctl", "enable", "--now", *units],
    )
