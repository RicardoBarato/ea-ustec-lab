import base64
import pathlib
import subprocess
import sys
import tempfile
import unittest

class PublicationGuardTest(unittest.TestCase):
    def run_guard(self, target):
        root = pathlib.Path(__file__).resolve().parents[1]
        return subprocess.run(
            [sys.executable, str(root / 'scripts' / 'publication_guard.py'), str(target)],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    def test_guard_passes(self):
        root = pathlib.Path(__file__).resolve().parents[1]
        result = self.run_guard(root)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_guard_rejects_blocked_term(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = pathlib.Path(tmp)
            (target / 'note.md').write_text(base64.b64decode('WEFV').decode('utf-8'), encoding='utf-8')
            result = self.run_guard(target)
        self.assertNotEqual(result.returncode, 0, result.stdout)

if __name__ == '__main__':
    unittest.main()
