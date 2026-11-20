import { StatusBar } from 'expo-status-bar';
import { useState } from 'react';
import { Linking, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';

import LogScreen from './LogScreen';
import SettingsScreen from './SettingsScreen';
import { Colors, useColors } from './theme';

const TABS = ['Bắt đầu', 'Cài đặt', 'Log'] as const;
type Tab = (typeof TABS)[number];

const STEPS = [
  'Bấm "Mở Cài đặt" bên dưới → Bàn phím → bật Kyx và bật "Cho phép Truy cập đầy đủ".',
  'Muốn dùng Kyx làm mặc định: Cài đặt → Cài đặt chung → Bàn phím → Bàn phím → Sửa → kéo Kyx lên đầu.',
  'Ô mật khẩu và ô số điện thoại luôn dùng bàn phím Apple (iOS bắt buộc).',
  'Chạm vào ô gõ thử, giữ nút 🌐 của iOS để chọn Kyx.',
];

export default function App() {
  const c = useColors();
  const s = styles(c);
  const [tab, setTab] = useState<Tab>('Bắt đầu');

  return (
    <View style={s.root}>
      <Text style={s.title}>Kyx</Text>
      <View style={s.tabs}>
        {TABS.map((t) => (
          <Pressable key={t} onPress={() => setTab(t)} style={[s.tab, tab === t && s.tabOn]}>
            <Text style={s.tabText}>{t}</Text>
          </Pressable>
        ))}
      </View>

      {tab === 'Bắt đầu' && (
        <ScrollView contentContainerStyle={s.page} keyboardShouldPersistTaps="handled">
          {STEPS.map((step, i) => (
            <View key={i} style={s.step}>
              <Text style={s.stepNum}>{i + 1}</Text>
              <Text style={s.stepText}>{step}</Text>
            </View>
          ))}
          <Pressable style={s.button} onPress={() => Linking.openSettings()}>
            <Text style={s.buttonText}>Mở Cài đặt</Text>
          </Pressable>
          <Text style={s.label}>Gõ thử ở đây</Text>
          <TextInput style={s.input} placeholder="tooi laf nguwowif Vieejt…" placeholderTextColor={c.muted} multiline />
          <Text style={s.hint}>
            Giữ phím cách để di chuyển con trỏ · giữ ⌫ rồi vuốt trái để xoá theo từ · giữ a e o u i y d để chọn chữ có dấu · phím VI/EN để đổi ngôn ngữ
          </Text>
        </ScrollView>
      )}
      {tab === 'Cài đặt' && <SettingsScreen />}
      {tab === 'Log' && <LogScreen />}

      <StatusBar style="auto" />
    </View>
  );
}

const styles = (c: Colors) => StyleSheet.create({
  root: { flex: 1, backgroundColor: c.bg, paddingTop: 64 },
  title: { fontSize: 32, fontWeight: '700', color: c.ink, paddingHorizontal: 16 },
  tabs: { flexDirection: 'row', margin: 16, marginBottom: 4, backgroundColor: c.seg, borderRadius: 9, padding: 2 },
  tab: { flex: 1, paddingVertical: 8, borderRadius: 7, alignItems: 'center' },
  tabOn: { backgroundColor: c.segOn },
  tabText: { color: c.ink, fontWeight: '600', fontSize: 14 },
  page: { padding: 16, gap: 12, paddingBottom: 48 },
  step: { flexDirection: 'row', gap: 12, alignItems: 'flex-start' },
  stepNum: { width: 24, height: 24, borderRadius: 12, backgroundColor: c.ink, color: c.bg, textAlign: 'center', lineHeight: 24, overflow: 'hidden', fontWeight: '600' },
  stepText: { flex: 1, fontSize: 15, lineHeight: 22, color: c.ink },
  button: { backgroundColor: c.blue, padding: 14, borderRadius: 10, alignItems: 'center', marginTop: 4 },
  buttonText: { color: '#fff', fontWeight: '600', fontSize: 16 },
  label: { marginTop: 12, fontSize: 15, fontWeight: '600', color: c.ink },
  input: { backgroundColor: c.card, borderRadius: 10, padding: 12, minHeight: 120, fontSize: 17, color: c.ink, textAlignVertical: 'top' },
  hint: { fontSize: 13, color: c.muted, lineHeight: 19 },
});
