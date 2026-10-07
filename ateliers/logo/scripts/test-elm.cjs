// Bound workers on large shared machines; the test runner otherwise uses every CPU.
const os = require('node:os');
const original = os.cpus;
os.cpus = () => original().slice(0, 2);
process.argv = [process.argv[0], require.resolve('elm-test/bin/elm-test'), ...process.argv.slice(2)];
require('elm-test/bin/elm-test');
