
import os
import unittest
import imp

_DIRNAME = os.path.dirname(os.path.abspath(__file__))
_SCRIPT = os.path.join(os.path.dirname(_DIRNAME), 'ayer-mock-config')

amc = imp.load_source('amc', _SCRIPT)

class TestCase(unittest.TestCase):
    @staticmethod
    def get_test_filename(filename):
        return os.path.join(_DIRNAME, 'mock_config_data', filename)

    def test_parse_args(self):
        result = amc.parseArgs([
            'key=value',
            'key2=value=with=eqs',
            'key with spaces=value with spaces'
        ])
        self.assertEqual(result, {
            'key': 'value',
            'key2': 'value=with=eqs',
            'key with spaces': 'value with spaces'
        });

    def test_var_replace(self):
        result = amc.varReplace(
            '$what is $which because of $foo',
            { 'what': 'ayer', 'which' : 'c00l' })
        self.assertEqual(result,
                         'ayer is c00l because of $foo')

    def test_read_config(self):
        filename = self.get_test_filename('read.cfg')
        result = amc.readConfig(filename)
        self.assertEqual(result, {
            'foo': True,
            'bar': 100500,
            'the multiline option': 'This\nis\nmultiline\noption\n'
        })

    def test_write_config(self):
        src = self.get_test_filename('read.cfg')
        dst = self.get_test_filename('write.cfg')
        orig = amc.readConfig(src)
        amc.writeConfig(dst, orig)
        config = amc.readConfig(dst)
        self.assertEqual(orig, config)

    def test_recursive_var_replace(self):
        victim = {
            'key': 'value',
            'subst': '$foo is $bar or $baz',
            'subdict': {
                'kkey': 'value',
                'also': 'make $foo'
            }
        }
        amc.recursiveVarReplace(victim, {'foo' : 'FOO', 'bar': 'BAR'})
        self.assertEqual(victim, {
            'key': 'value',
            'subst': 'FOO is BAR or $baz',
            'subdict': {
                'kkey': 'value',
                'also': 'make FOO'
            }
        })


if __name__ == '__main__':
    unittest.main()

