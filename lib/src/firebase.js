// src/firebase.js
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "XXXX",
  authDomain: "XXXX.firebaseapp.com",
  projectId: "XXXX",
  storageBucket: "XXXX.appspot.com",
  messagingSenderId: "XXXX",
  appId: "XXXX",
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export default app;
