// App.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { RootTabs } from './src/navigation/RootTabs';
import { UserIdProvider } from './src/context/UserIdContext';
import { SafeAreaProvider } from 'react-native-safe-area-context';

export default function App() {
  return (
    <SafeAreaProvider>
      <UserIdProvider>
        <NavigationContainer>
          <RootTabs />
        </NavigationContainer>
      </UserIdProvider>
    </SafeAreaProvider>
  );
}
