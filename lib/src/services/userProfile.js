import { doc, setDoc, serverTimestamp } from "firebase/firestore";
import { db } from "../firebase";

export async function createOrUpdateUserProfile(user) {
  if (!user?.uid) return;

  const ref = doc(db, "users", user.uid);

  await setDoc(
    ref,
    {
      uid: user.uid,
      email: user.email || null,
      displayName: user.displayName || null,
      photoURL: user.photoURL || null,
      createdAt: serverTimestamp(),
      lastSeenAt: serverTimestamp(),
    },
    { merge: true }
  );
}
