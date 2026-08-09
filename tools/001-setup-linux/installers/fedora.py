from __future__ import annotations

from .common import Distro, PackageInstaller, Runner


class FedoraInstaller(PackageInstaller):
    """Fedora-specific extension point for future repository/package logic."""

    def __init__(self, distro: Distro, runner: Runner) -> None:
        if distro.package_manager != "dnf":
            raise ValueError("FedoraInstaller yêu cầu dnf")
        super().__init__(distro, runner)
