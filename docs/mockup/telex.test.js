// Chạy: node docs/mockup/telex.test.js. Engine Swift (M2) dùng chung file vectors này.
const path = require('path');
const { telexType } = require('./telex.js');
const vectors = require(path.join(__dirname, '../../engine/Tests/TelexTests/Resources/telex-vectors.json'));
let fail = 0;
for (const t of vectors) {
  const got = telexType(t.keys, t.style);
  if (got !== t.out) { fail++; console.log(`FAIL ${JSON.stringify(t.keys)} (${t.style}) → ${got}, expected ${t.out}`); }
}
console.log(`${vectors.length - fail}/${vectors.length} pass`);
process.exit(fail ? 1 : 0);
