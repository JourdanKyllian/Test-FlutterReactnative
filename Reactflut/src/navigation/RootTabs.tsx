import React from 'react';
import { SafeAreaView } from 'react-native-safe-area-context';
import { createMaterialTopTabNavigator } from '@react-navigation/material-top-tabs';
import { HomeScreen } from '../screens/HomeScreen';
import { ProfileScreen } from '../screens/ProfileScreen';

/**
 * Paramètres de navigation
 */
export type RootTabParamList = {
  UserId: undefined;
  Profile: undefined;
};

const Tab = createMaterialTopTabNavigator<RootTabParamList>();

export const RootTabs: React.FC = () => {
  return (
    <SafeAreaView style={{ flex: 1 }}>
      <Tab.Navigator
        screenOptions={{
          tabBarIndicatorStyle: { backgroundColor: '#007AFF' },
          tabBarActiveTintColor: '#007AFF',
          tabBarInactiveTintColor: '#666',
          tabBarLabelStyle: { fontWeight: '600' },
          tabBarStyle: { height: 48},
        }}
      >
        <Tab.Screen
          name="UserId"
          component={HomeScreen}
          options={{ title: 'User ID' }}
        />
        <Tab.Screen
          name="Profile"
          component={ProfileScreen}
          options={{ title: 'Profil' }}
        />
      </Tab.Navigator>
    </SafeAreaView>
  );
};
