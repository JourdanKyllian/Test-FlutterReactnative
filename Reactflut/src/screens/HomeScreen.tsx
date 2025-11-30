import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Button,
  StyleSheet,
  Keyboard,
  TouchableWithoutFeedback,
} from 'react-native';
import { useUserId } from '../context/UserIdContext';


/**
 * Écran d'accueil de l'application
 */
export const HomeScreen: React.FC = () => {
  const [userIdInput, setUserIdInput] = useState<string>('');
  const { userId, setUserId } = useUserId();


  /**
   * Remplace les caractères non numériques par des espaces
   * @param {string} text the text to be processed
   */
  const handleChangeUserId = (text: string) => {
    const numericText = text.replace(/[^0-9]/g, '');
    setUserIdInput(numericText);
  };

  /**
   * Enregistrement de l'userId
   */
  const handleSave = () => {
    setUserId(userIdInput || null);
    setUserIdInput('');
    Keyboard.dismiss(); // ferme le clavier après sauvegarde
  };

  return (
    <TouchableWithoutFeedback onPress={Keyboard.dismiss} accessible={false}>
      <View style={styles.container}>
        <Text style={styles.label}>Entrez un userId (ex: 1 ou 3) :</Text>

        <TextInput
          style={styles.input}
          value={userIdInput}
          onChangeText={handleChangeUserId}
          keyboardType="number-pad"
          placeholder="userId"
        />

        <Button title="Save" onPress={handleSave} />

        {/* Affichage de l'userId global actuel */}
        <View style={styles.resultContainer}>
          <Text>UserId global actuel :</Text>
          <Text style={styles.savedValue}>
            {userId ?? 'Aucun pour le moment'}
          </Text>
        </View>
      </View>
    </TouchableWithoutFeedback>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, justifyContent: 'center' },
  label: { marginBottom: 8, fontSize: 16 },
  input: {
    borderWidth: 1,
    borderColor: '#ccc',
    paddingHorizontal: 12,
    paddingVertical: 8,
    marginBottom: 16,
    borderRadius: 4,
  },
  resultContainer: { marginTop: 24 },
  savedValue: { marginTop: 4, fontWeight: 'bold', fontSize: 16 },
});
