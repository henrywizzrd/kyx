import { useColorScheme } from 'react-native';

export function useColors() {
  const dark = useColorScheme() !== 'light';
  return dark
    ? { bg: '#000', card: '#1c1c1e', sep: '#38383a', ink: '#fff', muted: '#8e8e93', blue: '#0a84ff', red: '#ff453a', seg: '#2c2c2e', segOn: '#636366' }
    : { bg: '#f2f2f7', card: '#fff', sep: '#c6c6c8', ink: '#000', muted: '#6c6c70', blue: '#007aff', red: '#ff3b30', seg: '#e3e3e8', segOn: '#fff' };
}
export type Colors = ReturnType<typeof useColors>;
