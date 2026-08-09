from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("setup_linux", ROOT / "setup.py")
assert SPEC and SPEC.loader
SETUP = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SETUP)


class ConfigTests(unittest.TestCase):
    def test_merge_appends_and_deduplicates_lists(self) -> None:
        base = {"groups": {"dev": {"packages": ["git", "cmake"]}}}
        overlay = {"groups": {"dev": {"packages": ["cmake", "gcc"]}}}

        merged = SETUP._merge_config(base, overlay)

        self.assertEqual(merged["groups"]["dev"]["packages"], ["git", "cmake", "gcc"])
        self.assertEqual(base["groups"]["dev"]["packages"], ["git", "cmake"])

    def test_short_group_aliases_are_supported(self) -> None:
        groups = {"development": {}, "network": {}, "virtualization": {}}

        selected = SETUP.parse_groups(["dev,net", "virt"], groups)

        self.assertEqual(selected, ["development", "network", "virtualization"])

    def test_unknown_group_is_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "Nhóm không tồn tại"):
            SETUP.parse_groups(["missing"], {"base": {}})

    def test_fedora_overlay_adds_development_packages(self) -> None:
        config = SETUP.load_config("dnf")

        self.assertIn("gcc-c++", config["groups"]["development"]["packages"])
        self.assertEqual(config["groups"]["development"]["helpers"], ["uv"])


if __name__ == "__main__":
    unittest.main()
