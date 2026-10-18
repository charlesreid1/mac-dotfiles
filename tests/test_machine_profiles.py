"""Regression tests for unified dotfiles; never install into the real home."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class MachineProfilesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.home = self.base / "home with spaces"
        self.bin = self.base / "bin"
        self.home.mkdir()
        self.bin.mkdir()
        self.env = {
            "HOME": str(self.home),
            "PATH": f"{self.bin}:/usr/bin:/bin",
            "USER": "dotfiles-test",
            "TERM": "dumb",
            "TMPDIR": str(self.base),
            "TEST_HOSTNAME": "creid-mac",
        }
        self.mock("hostname", 'printf "%s\\n" "$TEST_HOSTNAME"\n')

    def mock(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/bash\n" + body)
        path.chmod(0o755)

    def run_command(self, args, *, check=True, **kwargs):
        result = subprocess.run(
            args, env=self.env, cwd=self.base, text=True,
            capture_output=True, **kwargs
        )
        if check:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def shell(self, script, **kwargs):
        return self.run_command(
            ["/bin/bash", "--noprofile", "--norc", "-c", script], **kwargs
        )

    def install(self, hostname="creid-mac"):
        self.env["TEST_HOSTNAME"] = hostname
        return self.run_command(["/bin/bash", str(ROOT / "bootstrap.sh"), "--force"])

    def config(self, key, directory=None, *, check=True):
        args = ["git"]
        if directory is not None:
            args.extend(["-C", str(directory)])
        # Normal Git config reads follow includes; --global alone does not.
        args.extend(["config", "--get", key])
        return self.run_command(args, check=check).stdout.strip()

    def test_bash_syntax(self):
        files = list(ROOT.glob("*.sh"))
        files += [ROOT / name for name in (
            ".bash_profile", ".bashrc", ".bash_prompt", ".aliases", ".exports"
        )]
        files += list((ROOT / ".config/dotfiles").rglob("*.sh"))
        for path in files:
            with self.subTest(file=path.name):
                self.run_command(["/bin/bash", "-n", str(path)])

    def test_detection_uses_hostname_not_hostname_variable(self):
        self.env["HOSTNAME"] = "kraken"
        cases = (
            ("creid-mac", "natty"), ("creid-mac.local", "natty"),
            ("natty", "natty"), ("kraken", "kraken"),
            ("kraken.example.com", "kraken"), ("other", "generic"),
        )
        for hostname, expected in cases:
            with self.subTest(hostname=hostname):
                self.env["TEST_HOSTNAME"] = hostname
                result = self.shell(
                    f'source "{ROOT}/.config/dotfiles/machine.sh"\n'
                    'printf "%s" "$DOTFILES_MACHINE"'
                )
                self.assertEqual(result.stdout, expected)

    def test_explicit_override(self):
        self.env["DOTFILES_MACHINE"] = "kraken"
        self.install()
        self.assertEqual(self.config("user.email"), "charlesreid1@gmail.com")

    def test_invalid_override_does_not_install(self):
        self.env["DOTFILES_MACHINE"] = "../../invalid"
        result = self.run_command(
            ["/bin/bash", str(ROOT / "bootstrap.sh"), "--force"], check=False
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unknown dotfiles machine profile", result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_natty_shell_has_only_work_setup(self):
        self.install("creid-mac.local")
        result = self.shell('''
shopt -s expand_aliases
source "$HOME/.bash_profile"
printf '%s\\n' "$DOTFILES_MACHINE" "$AWS_PROFILE" "$CLAUDE_CODE_USE_BEDROCK" "$AWS_CA_BUNDLE" "$PS1"
type -t claude
alias opencode vpp
alias gemini-pro claude-deep 2>/dev/null && exit 1
test -z "${ANTHROPIC_DEFAULT_OPUS_MODEL-}"
''')
        self.assertEqual(result.stderr, "")
        self.assertIn("natty\nclaude\n1\n", result.stdout)
        self.assertIn(str(self.home / ".aws/nskp_config/netskope-cert-bundle.pem"), result.stdout)
        self.assertIn("natty", result.stdout)
        self.assertIn("function\n", result.stdout)
        self.assertIn("aws-vault exec claude", result.stdout)
        self.assertIn("pypy3.11-7.3.20", result.stdout)

    def test_kraken_shell_has_only_personal_setup(self):
        self.install("kraken")
        result = self.shell('''
shopt -s expand_aliases
source "$HOME/.bash_profile"
printf '%s\\n' "$DOTFILES_MACHINE" "$ANTHROPIC_MODEL" "$PS1" "$LSCOLORS"
alias claude gemini-pro claude-deep omo-pd council vpp
test -z "${AWS_PROFILE-}${AWS_CA_BUNDLE-}${CLAUDE_CODE_USE_BEDROCK-}${OKTA_AWSCLI_ORG_DOMAIN-}${OPENCODE_CONFIG_REPO-}"
''')
        self.assertEqual(result.stderr, "")
        self.assertIn("kraken\nclaude-opus-5-5\n", result.stdout)
        self.assertIn("command claude --model", result.stdout)
        self.assertNotIn("aws-vault", result.stdout)

    def test_generic_shell_and_git_do_not_choose_an_identity(self):
        self.install("unrecognized.local")
        result = self.shell('''
source "$HOME/.bash_profile"
printf '%s\\n' "$DOTFILES_MACHINE" "$PS1"
test -z "${AWS_PROFILE-}${AWS_CA_BUNDLE-}${ANTHROPIC_MODEL-}"
''')
        self.assertEqual(result.stderr, "")
        self.assertIn("generic\n", result.stdout)
        self.assertIn("unrecognized", result.stdout)
        self.assertEqual(self.config("user.useConfigOnly"), "true")
        self.assertEqual(self.config("user.email", check=False), "")

    def test_git_identity_and_signing(self):
        for hostname, email, name, signing in (
            ("creid-mac", "creid@natera.com", "Chaz Reid", "true"),
            ("kraken", "charlesreid1@gmail.com", "Charles Reid", "false"),
        ):
            with self.subTest(hostname=hostname):
                self.install(hostname)
                self.assertEqual(self.config("user.email"), email)
                self.assertEqual(self.config("user.name"), name)
                self.assertEqual(self.config("commit.gpgsign"), signing)
                if hostname == "creid-mac":
                    self.assertEqual(
                        self.config("user.signingkey"),
                        "836EB56BCCC83AE08C8A6F966DCC6C631CC1CC59",
                    )
                else:
                    self.assertEqual(self.config("user.signingkey", check=False), "")

    def test_git_per_directory_overrides(self):
        for hostname, relative, email in (
            ("creid-mac", "charlesreid1/project", "charlesreid1@gmail.com"),
            ("kraken", "golly/project", "ch4zm.of.hellmouth@gmail.com"),
        ):
            with self.subTest(hostname=hostname):
                self.install(hostname)
                repo = self.home / relative
                repo.mkdir(parents=True)
                self.run_command(["git", "init", str(repo)])
                self.assertEqual(self.config("user.email", repo), email)

    def test_shell_reload_keeps_path_deduplicated_and_git_unchanged(self):
        for hostname in ("creid-mac", "kraken"):
            with self.subTest(hostname=hostname):
                self.install(hostname)
                before = (self.home / ".gitconfig_machine").read_bytes()
                result = self.shell('''
shopt -s expand_aliases
source "$HOME/.bash_profile"
source "$HOME/.bashrc"
printf '%s' "$PATH"
''')
                self.assertEqual(result.stderr, "")
                entries = result.stdout.split(":")
                self.assertEqual(len(entries), len(set(entries)))
                self.assertEqual((self.home / ".gitconfig_machine").read_bytes(), before)

    def test_optional_secrets_precede_aliases_and_extra_can_override(self):
        self.install("kraken")
        (self.home / ".deepseek_api_key").write_text("export DEEPSEEK_API_KEY=test-key\n")
        (self.home / ".extra").write_text("export ANTHROPIC_MODEL=local-override\n")
        result = self.shell('''
source "$HOME/.bash_profile"
printf '%s\\n' "$ANTHROPIC_MODEL"
alias claude-deep
''')
        self.assertEqual(result.stderr, "")
        self.assertIn("local-override", result.stdout)
        self.assertIn("test-key", result.stdout)

    def test_external_aliases_only_load_on_natty(self):
        external = self.home / "charlesreid1/opencode-config"
        external.mkdir(parents=True)
        (external / ".aliases").write_text("alias external-tool='echo external'\n")
        self.install()
        result = self.shell('source "$HOME/.bash_profile"\nalias external-tool')
        self.assertIn("echo external", result.stdout)
        self.install("kraken")
        result = self.shell('source "$HOME/.bash_profile"\nalias external-tool', check=False)
        self.assertNotEqual(result.returncode, 0)

    def test_install_excludes_repository_metadata_scripts_and_docs(self):
        self.install()
        for name in (
            ".git", ".gitignore", "bootstrap.sh", "bootstrap_exclude.txt",
            "README.md", "VIMRC_REFACTOR.md", "plan-general-improvements.md", "tests",
        ):
            self.assertFalse((self.home / name).exists(), name)
        for name in (
            ".bash_profile", ".vimrc", ".config/dotfiles/machine.sh",
            ".config/cmux/cmux.json", ".config/ghostty/config", ".config/uv/uv.toml",
            ".gitconfig_machine",
        ):
            self.assertTrue((self.home / name).is_file(), name)

    def test_diff_previews_new_and_selected_files_without_installing(self):
        self.env["TEST_HOSTNAME"] = "kraken"
        result = self.run_command(["/bin/bash", str(ROOT / "diff_dotfiles.sh")])
        self.assertIn("Previewing dotfiles for kraken", result.stdout)
        self.assertIn(str(self.home / ".gitconfig_machine"), result.stdout)
        self.assertIn(str(self.home / ".config/dotfiles/machine.sh"), result.stdout)
        self.assertIn("New file:", result.stdout)
        self.assertNotIn(str(self.home / "tests/test_machine_profiles.py"), result.stdout)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_declining_bootstrap_does_not_install(self):
        self.run_command(["/bin/bash", str(ROOT / "bootstrap.sh")], input="n\n")
        self.assertEqual(list(self.home.iterdir()), [])

    def test_confirming_bootstrap_handles_existing_file_differences(self):
        self.install()
        (self.home / ".bash_profile").write_text("# old profile\n")
        result = self.run_command(
            ["/bin/bash", str(ROOT / "bootstrap.sh")], input="y\n"
        )
        self.assertIn("-# old profile", result.stdout)
        self.assertEqual(
            (self.home / ".bash_profile").read_bytes(),
            (ROOT / ".bash_profile").read_bytes(),
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
