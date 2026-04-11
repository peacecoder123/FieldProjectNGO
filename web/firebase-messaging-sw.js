importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyClJI1xE6kr8_Eg3sjbobrFZkWLLFP2BD0",
  authDomain: "project-08d246f1-d6d3-42e6-a40.firebaseapp.com",
  projectId: "project-08d246f1-d6d3-42e6-a40",
  storageBucket: "project-08d246f1-d6d3-42e6-a40.firebasestorage.app",
  messagingSenderId: "562668242155",
  appId: "1:562668242155:web:84bd5e517e52e5f9192aae",
  measurementId: "G-R40MXX6M28"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background Message received: ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/favicon.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
