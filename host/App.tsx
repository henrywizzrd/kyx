import { ExtensionStorage } from '@bacons/apple-targets';
import { StatusBar } from 'expo-status-bar';
import { useState } from 'react';
import { Linking, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';

import { APP_GROUP, KEYS } from './shared';

const storage = new ExtensionStorage(APP_GROUP);

const steps = [
  'Mở Cài đặt → Cài đặt chung → Bàn phím → Bàn phím.',
  'Chọn "Thêm bàn phím mới…" rồi chọn Kyx.',
  'Bấm "Ghi ping" bên dưới, rồi chạm ô gõ thử và chuyển sang Kyx bằng phím 🌐.',
  'Trên bàn phím Kyx, bấm "Test" và chụp màn hình dòng trạng thái gửi cho Claude.',
];

export default function App() {
  const [hostPing, setHostPing] = useState<string | null>(null);
  const [keyboardPing, setKeyboardPing] = useState<string | null>(null);

  const writePing = () => {
    const value = new Date().toISOString();
    storage.set(KEYS.hostPing, value);
    setHostPing(storage.get(KEYS.hostPing));
  };

  const readKeyboardPing = () => setKeyboardPing(storage.get(KEYS.keyboardPing));

  return (
    <ScrollView contentContainerStyle={styles.container} keyboardShouldPersistTaps="handled">
      <Text style={styles.title}>Kyx</Text>
      <Text style={styles.subtitle}>M0 · kiểm tra chuỗi cài đặt + App Group</Text>

      {steps.map((s, i) => (
        <View key={i} style={styles.step}>
          <Text style={styles.stepNum}>{i + 1}</Text>
          <Text style={styles.stepText}>{s}</Text>
        </View>
      ))}

      <Pressable style={styles.button} onPress={() => Linking.openSettings()}>
        <Text style={styles.buttonText}>Mở Cài đặt</Text>
      </Pressable>

      <View style={styles.row}>
        <Pressable style={[styles.button, styles.flex]} onPress={writePing}>
          <Text style={styles.buttonText}>Ghi ping</Text>
        </Pressable>
        <Pressable style={[styles.button, styles.flex]} onPress={readKeyboardPing}>
          <Text style={styles.buttonText}>Đọc ping bàn phím</Text>
        </Pressable>
      </View>
      <Text style={styles.mono}>host.ping (app đọc lại): {hostPing ?? '—'}</Text>
      <Text style={styles.mono}>keyboard.ping: {keyboardPing ?? '—'}</Text>

      <Text style={styles.label}>Gõ thử ở đây:</Text>
      <TextInput style={styles.input} placeholder="Chạm để gõ…" multiline />

      <StatusBar style="auto" />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { padding: 24, paddingTop: 72, gap: 12 },
  title: { fontSize: 32, fontWeight: '700' },
  subtitle: { fontSize: 16, color: '#666', marginBottom: 8 },
  step: { flexDirection: 'row', gap: 12, alignItems: 'flex-start' },
  stepNum: { width: 24, height: 24, borderRadius: 12, backgroundColor: '#222', color: '#fff', textAlign: 'center', lineHeight: 24, overflow: 'hidden' },
  stepText: { flex: 1, fontSize: 15, lineHeight: 22 },
  row: { flexDirection: 'row', gap: 8 },
  flex: { flex: 1 },
  button: { backgroundColor: '#007AFF', padding: 14, borderRadius: 10, alignItems: 'center', marginTop: 8 },
  buttonText: { color: '#fff', fontWeight: '600', fontSize: 15 },
  mono: { fontFamily: 'Menlo', fontSize: 12, color: '#333' },
  label: { marginTop: 16, fontSize: 15, fontWeight: '600' },
  input: { borderWidth: 1, borderColor: '#ccc', borderRadius: 10, padding: 12, minHeight: 100, fontSize: 16 },
});
