from __future__ import annotations

import logging
import os
import shlex
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence


@dataclass(frozen=True)
class Distro:
    distro_id: str
    id_like: tuple[str, ...]
    version: str
    pretty_name: str
    package_manager: str


@dataclass(frozen=True)
class StepResult:
    name: str
    succeeded: bool
    skipped: bool = False
    returncode: int | None = None


def _read_os_release(path: Path = Path("/etc/os-release")) -> dict[str, str]:
    if not path.is_file():
        raise RuntimeError(f"Không tìm thấy {path}")

    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        try:
            parsed = shlex.split(value, posix=True)
            values[key] = parsed[0] if parsed else ""
        except ValueError:
            values[key] = value.strip('"\'')
    return values


def detect_distro(path: Path = Path("/etc/os-release")) -> Distro:
    values = _read_os_release(path)
    distro_id = values.get("ID", "unknown").lower()
    id_like = tuple(values.get("ID_LIKE", "").lower().split())

    families = {
        "dnf": {"fedora", "rhel", "centos", "rocky", "almalinux"},
        "apt": {"debian", "ubuntu", "linuxmint", "pop", "elementary", "zorin"},
        "pacman": {"arch", "endeavouros", "manjaro", "cachyos", "garuda"},
        "zypper": {"opensuse", "opensuse-tumbleweed", "opensuse-leap", "sles", "sled"},
        "xbps": {"void"},
    }
    package_manager = ""
    identifiers = {distro_id, *id_like}
    for manager, names in families.items():
        if identifiers & names:
            package_manager = manager
            break

    if not package_manager:
        raise RuntimeError(
            f"Distro chưa được hỗ trợ: {values.get('PRETTY_NAME', distro_id)}"
        )
    executable = {
        "apt": "apt-get",
        "xbps": "xbps-install",
    }.get(package_manager, package_manager)
    if shutil.which(executable) is None:
        raise RuntimeError(f"Không tìm thấy package manager: {executable}")

    return Distro(
        distro_id=distro_id,
        id_like=id_like,
        version=values.get("VERSION_ID", "unknown"),
        pretty_name=values.get("PRETTY_NAME", distro_id),
        package_manager=package_manager,
    )


class Runner:
    def __init__(self, *, dry_run: bool = False) -> None:
        self.dry_run = dry_run
        self.results: list[StepResult] = []
        self.log = logging.getLogger("setup-linux")

    @staticmethod
    def format_command(command: Sequence[str]) -> str:
        return shlex.join(str(part) for part in command)

    def run(
        self,
        name: str,
        command: Sequence[str],
        *,
        env: dict[str, str] | None = None,
    ) -> bool:
        printable = self.format_command(command)
        prefix = "[DRY-RUN]" if self.dry_run else "$"
        print(f"\n{prefix} {printable}")
        self.log.info("Bước %s: %s", name, printable)

        if self.dry_run:
            self.results.append(StepResult(name, True, skipped=True))
            return True

        try:
            subprocess.run(
                [str(part) for part in command],
                check=True,
                env={**os.environ, **(env or {})},
            )
        except FileNotFoundError:
            self.log.exception("Không tìm thấy lệnh cho bước %s", name)
            self.results.append(StepResult(name, False, returncode=127))
            return False
        except subprocess.CalledProcessError as error:
            self.log.error("Bước %s thất bại (mã %s)", name, error.returncode)
            self.results.append(StepResult(name, False, returncode=error.returncode))
            return False

        self.results.append(StepResult(name, True, returncode=0))
        return True

    def summary(self) -> bool:
        succeeded = sum(result.succeeded and not result.skipped for result in self.results)
        simulated = sum(result.skipped for result in self.results)
        failed = [result for result in self.results if not result.succeeded]
        print("\n=== TÓM TẮT ===")
        print(f"Thành công: {succeeded} | Mô phỏng: {simulated} | Thất bại: {len(failed)}")
        for result in failed:
            print(f"  [LỖI] {result.name} (mã {result.returncode})")
        return not failed


class PackageInstaller:
    COMMANDS = {
        "dnf": ["sudo", "dnf", "install", "-y"],
        "apt": ["sudo", "apt-get", "install", "-y"],
        "pacman": ["sudo", "pacman", "-S", "--needed", "--noconfirm"],
        "zypper": ["sudo", "zypper", "--non-interactive", "install"],
        "xbps": ["sudo", "xbps-install", "-Sy"],
    }

    def __init__(self, distro: Distro, runner: Runner) -> None:
        self.distro = distro
        self.runner = runner
        self._apt_updated = False

    def install(self, group: str, packages: Iterable[str]) -> bool:
        package_list = list(dict.fromkeys(packages))
        if not package_list:
            return True

        if self.distro.package_manager == "apt" and not self._apt_updated:
            if not self.runner.run("Cập nhật APT index", ["sudo", "apt-get", "update"]):
                return False
            self._apt_updated = True

        command = [*self.COMMANDS[self.distro.package_manager], *package_list]
        return self.runner.run(f"Cài package nhóm {group}", command)
