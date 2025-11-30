import React, { createContext, useContext, useState } from 'react';

/**
 * Contexte pour stocker et modifier l'userId
 */
type UserIdContextValue = {
  userId: string | null;
  setUserId: (id: string | null) => void;
};

const UserIdContext = createContext<UserIdContextValue | undefined>(undefined);

/**
 * Provider pour le contexte d'userId
 * @param param0 
 * @returns 
 */
export const UserIdProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [userId, setUserId] = useState<string | null>(null);

  return (
    <UserIdContext.Provider value={{ userId, setUserId }}>
      {children}
    </UserIdContext.Provider>
  );
};

/**
 * Renvoie l'objet contenant l'userId et les méthodes pour le modifier
 * @returns L'objet contenant l'userId
 * @throws {Error} Si useUserId est appelé en dehors d'un UserIdProvider
 */
export const useUserId = (): UserIdContextValue => {
  const context = useContext(UserIdContext);
  if (!context) {
    throw new Error('useUserId doit être appelé dans un UserIdProvider');
  }
  return context;
};
