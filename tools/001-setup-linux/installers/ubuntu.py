from __future__ import annotations

from .common import Distro, PackageInstaller, Runner


class UbuntuInstaller(PackageInstaller):
    """Debian/Ubuntu-specific extension point with one APT update per run."""

    def __init__(self, distro: Distro, runner: Runner) -> None:
        if distro.package_manager != "apt":
            raise ValueError("UbuntuInstaller yêu cầu apt")
        super().__init__(distro, runner)
