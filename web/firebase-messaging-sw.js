importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

const firebaseConfig = {
    apiKey: "AIzaSyBREdiDdOJNdvJDIRYrLYraWNVlalSvlJs",
    authDomain: "flutter-tutorial-843d7.firebaseapp.com",
    projectId: "flutter-tutorial-843d7",
    storageBucket: "flutter-tutorial-843d7.appspot.com",
    messagingSenderId: "897956436289",
    appId: "1:897956436289:web:a88b4ac73fb4baced4a9c0",
    measurementId: "G-8WJ0DL1N8V"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});


