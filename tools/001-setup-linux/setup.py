#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import logging
import re
import sys
from copy import deepcopy
from pathlib import Path
from typing import Any

from installers.common import PackageInstaller, Runner, detect_distro
from installers.fedora import FedoraInstaller
from installers.flatpak import install_flatpaks
from installers.services import enable_services
from installers.ubuntu import UbuntuInstaller


ROOT = Path(__file__).resolve().parent
CONFIG_DIR = ROOT / "config"
MODULES_DIR = ROOT / "modules"
GROUP_ALIASES = {"dev": "development", "net": "network", "virt": "virtualization"}


def _merge_config(base: dict[str, Any], overlay: dict[str, Any]) -> dict[str, Any]:
    merged = deepcopy(base)
    for key, value in overlay.items():
        if key != "groups":
            if isinstance(value, dict) and isinstance(merged.get(key), dict):
                merged[key].update(value)
            else:
                merged[key] = deepcopy(value)
            continue

        groups = merged.setdefault("groups", {})
        for group_name, additions in value.items():
            group = groups.setdefault(group_name, {})
            for field, field_value in additions.items():
                if isinstance(field_value, list):
                    group[field] = list(dict.fromkeys([*group.get(field, []), *field_value]))
                else:
                    group[field] = field_value
    return merged


def _read_json(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise RuntimeError(f"Thiếu file cấu hình: {path}") from error
    except json.JSONDecodeError as error:
        raise RuntimeError(f"JSON không hợp lệ trong {path}: {error}") from error


def load_config(package_manager: str) -> dict[str, Any]:
    config = _read_json(CONFIG_DIR / "common.json")
    family_file = {
        "dnf": "fedora.json",
        "apt": "ubuntu.json",
        "pacman": "arch.json",
    }.get(package_manager)
    if family_file:
        config = _merge_config(config, _read_json(CONFIG_DIR / family_file))
    return config


def configure_logging(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        filename=path,
        level=logging.INFO,
        encoding="utf-8",
        format="%(asctime)s %(levelname)s %(message)s",
    )


def parse_groups(values: list[str], available: dict[str, Any]) -> list[str]:
    requested: list[str] = []
    for value in values:
        for raw_name in value.split(","):
            name = GROUP_ALIASES.get(raw_name.strip().lower(), raw_name.strip().lower())
            if name and name not in requested:
                requested.append(name)

    unknown = [name for name in requested if name not in available]
    if unknown:
        choices = ", ".join(available)
        raise ValueError(f"Nhóm không tồn tại: {', '.join(unknown)}. Các nhóm: {choices}")
    return requested


def choose_groups(groups: dict[str, Any]) -> list[str]:
    names = list(groups)
    print("\nChọn các nhóm cần cài (cách nhau bằng dấu phẩy):")
    for index, name in enumerate(names, start=1):
        optional = " [tùy chọn]" if groups[name].get("optional") else ""
        print(f"  {index:>2}) {name:<15} {groups[name].get('description', '')}{optional}")
    print("   0) Thoát")

    answer = input("Lựa chọn: ").strip()
    if answer == "0":
        return []
    selected: list[str] = []
    for token in answer.split(","):
        token = token.strip()
        if not token.isdigit() or not 1 <= int(token) <= len(names):
            raise ValueError(f"Lựa chọn không hợp lệ: {token or '(trống)'}")
        name = names[int(token) - 1]
        if name not in selected:
            selected.append(name)
    return selected


def make_package_installer(package_manager: str, runner: Runner) -> PackageInstaller:
    distro = detect_distro()
    if distro.package_manager != package_manager:
        raise RuntimeError("Package manager đã thay đổi trong lúc chạy")
    if package_manager == "dnf":
        return FedoraInstaller(distro, runner)
    if package_manager == "apt":
        return UbuntuInstaller(distro, runner)
    return PackageInstaller(distro, runner)


def run_helper(runner: Runner, helper_name: str, helper: dict[str, str]) -> bool:
    module_name = helper.get("module", "")
    function_name = helper.get("function", "")
    if not re.fullmatch(r"[a-zA-Z0-9_-]+\.sh", module_name):
        raise RuntimeError(f"Tên module helper không an toàn: {module_name!r}")
    if not re.fullmatch(r"[a-zA-Z_][a-zA-Z0-9_]*", function_name):
        raise RuntimeError(f"Tên hàm helper không an toàn: {function_name!r}")

    common = MODULES_DIR / "common.sh"
    module = MODULES_DIR / module_name
    if not common.is_file() or not module.is_file():
        raise RuntimeError(f"Không tìm thấy Bash helper cho {helper_name}: {module}")

    shell = 'source "$1"; source "$2"; detect_distro; prepare_sudo; "$3"'
    return runner.run(
        f"Bash helper: {helper_name}",
        ["bash", "-c", shell, "setup-linux", str(common), str(module), function_name],
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Điều phối cài đặt Linux bằng Python, giữ Bash cho tác vụ đặc thù.",
    )
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument(
        "--only",
        action="append",
        default=[],
        metavar="GROUP",
        help="Chỉ chạy nhóm chỉ định; có thể lặp hoặc phân cách bằng dấu phẩy.",
    )
    selection.add_argument(
        "--all",
        action="store_true",
        help="Chạy mọi nhóm không được đánh dấu tùy chọn.",
    )
    parser.add_argument(
        "--include-optional",
        action="store_true",
        help="Kèm nhóm tùy chọn khi dùng --all (ví dụ driver NVIDIA).",
    )
    parser.add_argument("--dry-run", action="store_true", help="Chỉ in lệnh, không thay đổi hệ thống.")
    parser.add_argument("--list-groups", action="store_true", help="Liệt kê nhóm rồi thoát.")
    parser.add_argument(
        "--log-file",
        type=Path,
        default=ROOT / "setup-linux.log",
        help="Đường dẫn file log (mặc định: setup-linux.log).",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.include_optional and not args.all:
        build_parser().error("--include-optional chỉ dùng cùng --all")
    configure_logging(args.log_file.expanduser())

    try:
        distro = detect_distro()
        config = load_config(distro.package_manager)
        groups: dict[str, Any] = config["groups"]
        print(f"Phát hiện: {distro.pretty_name} ({distro.package_manager})")

        if args.list_groups:
            for name, group in groups.items():
                optional = " [tùy chọn]" if group.get("optional") else ""
                print(f"{name}{optional}: {group.get('description', '')}")
            return 0

        if args.only:
            selected = parse_groups(args.only, groups)
        elif args.all:
            selected = [
                name for name, group in groups.items()
                if args.include_optional or not group.get("optional")
            ]
        elif sys.stdin.isatty():
            selected = choose_groups(groups)
        else:
            raise RuntimeError("Cần dùng --only, --all hoặc --list-groups khi chạy không tương tác")

        if not selected:
            print("Không có nhóm nào được chọn.")
            return 0

        print(f"Nhóm sẽ chạy: {', '.join(selected)}")
        runner = Runner(dry_run=args.dry_run)
        package_installer = make_package_installer(distro.package_manager, runner)
        helpers = config.get("helpers", {})

        for group_name in selected:
            group = groups[group_name]
            package_installer.install(group_name, group.get("packages", []))
            install_flatpaks(runner, group.get("flatpaks", []))
            enable_services(runner, group.get("services", []))
            for helper_name in group.get("helpers", []):
                if helper_name not in helpers:
                    raise RuntimeError(f"Helper chưa được định nghĩa: {helper_name}")
                run_helper(runner, helper_name, helpers[helper_name])

        return 0 if runner.summary() else 1
    except (KeyboardInterrupt, EOFError):
        print("\nĐã hủy.", file=sys.stderr)
        return 130
    except (RuntimeError, ValueError, KeyError) as error:
        logging.getLogger("setup-linux").exception("Không thể tiếp tục")
        print(f"Lỗi: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
