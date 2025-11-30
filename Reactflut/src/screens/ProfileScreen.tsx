// src/screens/FlutterProfileScreen.tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useUserId } from '../context/UserIdContext';

/**
 * Profil venant du SDK de Flutter
 */
export const ProfileScreen: React.FC = () => {
  const { userId } = useUserId();

  return (
    <View style={styles.container}>
      <Text>Profil Flutter (SDK) sera intégré ici</Text>
      <Text style={styles.info}>
        userId courant (global) : {userId ?? 'Aucun userId défini'}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  info: { marginTop: 12, fontSize: 16 },
});
