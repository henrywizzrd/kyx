// Kyx Telex engine (bản JS cho bản mẫu). Engine Swift ở engine/ phải cho ra
// kết quả giống hệt, kiểm bằng engine/Tests/TelexTests/telex-vectors.json.
//
// telexApply(word, key, style) -> word mới
//   word : các chữ cái ngay trước con trỏ (chỉ chữ cái)
//   key  : 1 ký tự chữ cái vừa gõ
//   style: 'new' (hoà, thuỷ) | 'old' (hòa, thủy)
(function (root) {
  const TONED = {
    'a': 'aáàảãạ', 'ă': 'ăắằẳẵặ', 'â': 'âấầẩẫậ', 'e': 'eéèẻẽẹ', 'ê': 'êếềểễệ', 'i': 'iíìỉĩị',
    'o': 'oóòỏõọ', 'ô': 'ôốồổỗộ', 'ơ': 'ơớờởỡợ', 'u': 'uúùủũụ', 'ư': 'ưứừửữự', 'y': 'yýỳỷỹỵ',
  };
  const TONE_KEYS = { s: 1, f: 2, r: 3, x: 4, j: 5, z: 0 };
  const CIRC = { a: 'â', e: 'ê', o: 'ô' };
  const MARKED = new Set(['ă', 'â', 'ê', 'ô', 'ơ', 'ư']);
  const ROOT = { 'ă': 'a', 'â': 'a', 'ê': 'e', 'ô': 'o', 'ơ': 'o', 'ư': 'u' };

  const LOOKUP = {};
  for (const base in TONED) [...TONED[base]].forEach((c, t) => { LOOKUP[c] = { base, tone: t }; });

  function parse(word) {
    return [...word].map((ch) => {
      const lower = ch.toLowerCase();
      const v = LOOKUP[lower];
      return { base: v ? v.base : lower, tone: v ? v.tone : 0, upper: ch !== lower };
    });
  }
  const isVowel = (c) => c.base in TONED;
  function render(cs) {
    return cs.map((c) => {
      const ch = isVowel(c) ? TONED[c.base][c.tone] : c.base;
      return c.upper ? ch.toUpperCase() : ch;
    }).join('');
  }

  // Cụm nguyên âm cuối cùng của từ (đã bỏ u trong "qu" và i trong "gi").
  function cluster(cs) {
    let end = -1;
    for (let i = cs.length - 1; i >= 0; i--) if (isVowel(cs[i])) { end = i; break; }
    if (end < 0) return [];
    let start = end;
    while (start > 0 && isVowel(cs[start - 1])) start--;
    const idx = [];
    for (let i = start; i <= end; i++) idx.push(i);
    if (idx.length > 1 && start > 0 && cs[start - 1].base === 'q' && cs[start].base === 'u') idx.shift();
    else if (idx.length > 1 && start === 1 && cs[0].base === 'g' && cs[1].base === 'i') idx.shift();
    return idx;
  }

  function tonePosition(cs, style) {
    const c = cluster(cs);
    if (c.length === 0) return -1;
    const horn = c.find((i) => cs[i].base === 'ơ');
    if (horn !== undefined) return horn;
    const marked = c.find((i) => MARKED.has(cs[i].base));
    if (marked !== undefined) return marked;
    if (c.length === 1) return c[0];
    if (c.length >= 3) return c[1];
    const hasFinal = c[1] < cs.length - 1;
    if (hasFinal) return c[1];
    const pair = cs[c[0]].base + cs[c[1]].base;
    if (['oa', 'oe', 'uy'].includes(pair)) return style === 'old' ? c[0] : c[1];
    return c[0];
  }

  function currentTone(cs) {
    for (const c of cs) if (isVowel(c) && c.tone) return c.tone;
    return 0;
  }

  // Xoá dấu thanh khỏi mọi nguyên âm rồi đặt lại vào đúng vị trí.
  function normalize(cs, style, tone) {
    cs.forEach((c) => { if (isVowel(c)) c.tone = 0; });
    if (!tone) return cs;
    const p = tonePosition(cs, style);
    if (p >= 0) cs[p].tone = tone;
    return cs;
  }

  function literal(cs, key) {
    const lower = key.toLowerCase();
    cs.push({ base: lower, tone: 0, upper: key !== lower });
  }

  function telexApply(word, key, style) {
    style = style || 'new';
    const cs = parse(word);
    const k = key.toLowerCase();
    let tone = currentTone(cs);

    if (k in TONE_KEYS) {
      const t = TONE_KEYS[k];
      if (cluster(cs).length === 0 || (t === 0 && tone === 0)) { literal(cs, key); }
      else if (t !== 0 && t === tone) { tone = 0; literal(cs, key); }      // gõ lại = bỏ dấu
      else tone = t;
      return render(normalize(cs, style, tone));
    }

    const c = cluster(cs);
    if (k in CIRC) {                                                      // aa ee oo
      const plain = [...c].reverse().find((i) => cs[i].base === k);
      const done = [...c].reverse().find((i) => cs[i].base === CIRC[k]);
      if (plain !== undefined) cs[plain].base = CIRC[k];
      else if (done !== undefined) { cs[done].base = k; literal(cs, key); } // aaa = aa
      else literal(cs, key);
    } else if (k === 'd') {                                               // dd = đ
      if (cs.length && cs[0].base === 'd') cs[0].base = 'đ';
      else if (cs.length && cs[0].base === 'đ') { cs[0].base = 'd'; literal(cs, key); }
      else literal(cs, key);
    } else if (k === 'w') {                                               // aw ow uw uow
      const find = (b) => [...c].reverse().find((i) => cs[i].base === b);
      const u = c.find((i) => cs[i].base === 'u'), o = find('o');
      if (u !== undefined && o !== undefined && o === u + 1) { cs[u].base = 'ư'; cs[o].base = 'ơ'; }
      else if (o !== undefined) cs[o].base = 'ơ';
      else if (u !== undefined) cs[u].base = 'ư';
      else if (find('a') !== undefined) cs[find('a')].base = 'ă';
      else if (c.length === 1 && c[0] === cs.length - 1 && cs[c[0]].base === 'ư') {
        cs[c[0]] = { base: 'w', tone: 0, upper: key !== k };                // ww = w (chữ ư đứng riêng)
      }
      else if (c.some((i) => ['ă', 'ơ', 'ư'].includes(cs[i].base))) {    // gõ lại w = bỏ móc
        c.forEach((i) => { if (['ă', 'ơ', 'ư'].includes(cs[i].base)) cs[i].base = ROOT[cs[i].base]; });
        literal(cs, key);
      } else if (c.length === 0 && (cs.length === 0 || cs[cs.length - 1].base !== 'w')) cs.push({ base: 'ư', tone: 0, upper: key !== k });
      else literal(cs, key);
    } else {
      literal(cs, key);
    }
    return render(normalize(cs, style, tone));
  }

  // Gõ cả chuỗi phím (dùng cho test).
  function telexType(keys, style) {
    let out = '';
    for (const ch of keys) {
      if (/\p{L}/u.test(ch)) {
        const m = out.match(/\p{L}+$/u);
        const word = m ? m[0] : '';
        out = out.slice(0, out.length - word.length) + telexApply(word, ch, style);
      } else out += ch;
    }
    return out;
  }

  root.KyxTelex = { telexApply, telexType };
  if (typeof module !== 'undefined') module.exports = root.KyxTelex;
})(typeof window !== 'undefined' ? window : globalThis);
