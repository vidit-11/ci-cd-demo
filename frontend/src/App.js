import React, { useEffect, useState } from 'react';

function App() {
  const [message, setMessage] = useState("Connecting to backend...");

  useEffect(() => {
    // Fetches from the Java Controller endpoint
    fetch('/api/status')
      .then(response => response.text())
      .then(data => setMessage(data))
      .catch(err => setMessage("Backend unreachable"));
  }, []);

  return (
    <div style={{ textAlign: 'center', marginTop: '50px', fontFamily: 'Arial' }}>
      <h1>Java + React CI/CD Demo</h1>
      <div style={{ padding: '20px', border: '1px solid #ccc', display: 'inline-block' }}>
        <p><strong>Server Status:</strong> {message}</p>
      </div>
      <p>Deployed via Jenkins to Tomcat in Docker.</p>
    </div>
  );
}

export default App;