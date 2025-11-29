import { useEffect } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "./firebase";
import { createOrUpdateUserProfile } from "./services/userProfile";

export default function AppAuthListener() {
  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (user) => {
      if (user) {
        await createOrUpdateUserProfile(user);
      }
    });

    return () => unsub();
  }, []);

  return null;
}
