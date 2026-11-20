import { useCallback, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';

import { clearLog, readLog } from './settings';
import { Colors, useColors } from './theme';

// Log do bàn phím ghi vào App Group (cần bật Full Access). Mới nhất ở trên.
export default function LogScreen() {
  const c = useColors();
  const s = styles(c);
  const [lines, setLines] = useState<string[]>(readLog);
  const refresh = useCallback(() => setLines(readLog()), []);

  return (
    <View style={s.page}>
      <View style={s.bar}>
        <Pressable style={s.btn} onPress={refresh}><Text style={s.btnText}>Làm mới</Text></Pressable>
        <Pressable style={s.btn} onPress={() => { clearLog(); refresh(); }}><Text style={[s.btnText, { color: c.red }]}>Xoá log</Text></Pressable>
      </View>
      <FlatList
        data={lines}
        keyExtractor={(_, i) => String(i)}
        contentContainerStyle={s.list}
        ListEmptyComponent={<Text style={s.empty}>Chưa có log. Mở bàn phím Kyx ở app bất kỳ rồi quay lại bấm Làm mới. Nếu vẫn trống, kiểm tra đã bật Full Access chưa.</Text>}
        renderItem={({ item }) => <Text style={s.line}>{item}</Text>}
      />
    </View>
  );
}

const styles = (c: Colors) => StyleSheet.create({
  page: { flex: 1 },
  bar: { flexDirection: 'row', gap: 8, paddingHorizontal: 16, paddingTop: 8 },
  btn: { flex: 1, backgroundColor: c.card, borderRadius: 10, padding: 12, alignItems: 'center' },
  btnText: { color: c.blue, fontWeight: '600', fontSize: 15 },
  list: { padding: 16, gap: 6 },
  empty: { color: c.muted, fontSize: 14, lineHeight: 20 },
  line: { color: c.ink, fontFamily: 'Menlo', fontSize: 12 },
});
