import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Switch, Text, View } from 'react-native';

import { DEFAULTS, KyxSettings, loadSettings, saveSettings } from './settings';
import { Colors, useColors } from './theme';

type Toggle = { k: keyof KyxSettings; t: string; d?: string };
type Seg = { k: keyof KyxSettings; t: string; d?: string; options: [string, string][] };

const GROUPS: [string, (Toggle | Seg)[]][] = [
  ['Phản hồi khi gõ', [
    { k: 'click', t: 'Âm click', d: 'Âm phím của hệ thống' },
    { k: 'haptic', t: 'Rung nhẹ', d: 'Cần bật Full Access cho Kyx' },
  ]],
  ['Gõ chữ', [
    { k: 'autocap', t: 'Tự viết hoa đầu câu' },
    { k: 'doubleSpace', t: 'Chạm cách 2 lần ra dấu chấm' },
    { k: 'tone', t: 'Kiểu bỏ dấu', d: 'hoà, thuỷ (mới) hay hòa, thủy (cũ)', options: [['new', 'hoà'], ['old', 'hòa']] },
    { k: 'defaultLang', t: 'Ngôn ngữ mặc định', options: [['VI', 'VI'], ['EN', 'EN']] },
  ]],
  ['Giao diện', [
    { k: 'theme', t: 'Theme', options: [['system', 'Hệ thống'], ['light', 'Sáng'], ['dark', 'Tối']] },
  ]],
];

export default function SettingsScreen() {
  const c = useColors();
  const s = styles(c);
  const [settings, setSettings] = useState<KyxSettings>(loadSettings);

  const update = (patch: Partial<KyxSettings>) => {
    const next = { ...settings, ...patch };
    setSettings(next);
    saveSettings(next);
  };

  const step = (delta: number) =>
    update({ height: Math.round(Math.min(1.2, Math.max(0.85, settings.height + delta)) * 100) / 100 });

  return (
    <ScrollView contentContainerStyle={s.page}>
      {GROUPS.map(([title, items]) => (
        <View key={title}>
          <Text style={s.groupTitle}>{title}</Text>
          <View style={s.group}>
            {items.map((it, i) => (
              <View key={it.k} style={[s.item, i > 0 && s.itemSep]}>
                <View style={s.flex}>
                  <Text style={s.label}>{it.t}</Text>
                  {it.d ? <Text style={s.desc}>{it.d}</Text> : null}
                </View>
                {'options' in it ? (
                  <View style={s.seg}>
                    {it.options.map(([v, l]) => (
                      <Pressable key={v} onPress={() => update({ [it.k]: v } as Partial<KyxSettings>)}
                        style={[s.segBtn, settings[it.k] === v && s.segOn]}>
                        <Text style={s.segText}>{l}</Text>
                      </Pressable>
                    ))}
                  </View>
                ) : (
                  <Switch value={settings[it.k] as boolean} onValueChange={(v) => update({ [it.k]: v } as Partial<KyxSettings>)} />
                )}
              </View>
            ))}
            {title === 'Giao diện' && (
              <View style={[s.item, s.itemSep]}>
                <View style={s.flex}>
                  <Text style={s.label}>Chiều cao phím</Text>
                  <Text style={s.desc}>{Math.round(settings.height * 100)}%</Text>
                </View>
                <View style={s.seg}>
                  <Pressable onPress={() => step(-0.05)} style={s.segBtn}><Text style={s.segText}>−</Text></Pressable>
                  <Pressable onPress={() => step(0.05)} style={s.segBtn}><Text style={s.segText}>+</Text></Pressable>
                </View>
              </View>
            )}
          </View>
        </View>
      ))}
      <Text style={s.note}>Cài đặt được lưu vào App Group. Bàn phím đọc lại mỗi lần mở.</Text>
      <Pressable style={[s.group, s.item, s.reset]} onPress={() => update({ ...DEFAULTS })}>
        <Text style={[s.label, { color: c.red }]}>Khôi phục mặc định</Text>
      </Pressable>
    </ScrollView>
  );
}

const styles = (c: Colors) => StyleSheet.create({
  page: { padding: 16, paddingBottom: 48 },
  groupTitle: { marginTop: 18, marginBottom: 6, marginLeft: 12, fontSize: 13, color: c.muted },
  group: { backgroundColor: c.card, borderRadius: 12, overflow: 'hidden' },
  item: { flexDirection: 'row', alignItems: 'center', gap: 12, minHeight: 48, paddingVertical: 8, paddingHorizontal: 14 },
  itemSep: { borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: c.sep },
  flex: { flex: 1 },
  label: { fontSize: 16, color: c.ink },
  desc: { fontSize: 12, color: c.muted, marginTop: 2 },
  seg: { flexDirection: 'row', backgroundColor: c.seg, borderRadius: 8, padding: 2 },
  segBtn: { paddingVertical: 7, paddingHorizontal: 12, borderRadius: 6, minWidth: 40, alignItems: 'center' },
  segOn: { backgroundColor: c.segOn },
  segText: { fontSize: 14, color: c.ink },
  note: { marginTop: 8, marginHorizontal: 12, fontSize: 12, color: c.muted },
  reset: { marginTop: 16, justifyContent: 'center' },
});
